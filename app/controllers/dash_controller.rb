class DashController < ApplicationController
  def chart
    hours = (params[:hours] || 8).to_i
    start = params[:start] ? Time.parse(params[:start]) : Time.now - hours.hours
    stop = start + hours.hours

    if stale?(Snapshot.latest)
      snapshots = Snapshot.includes(:exchange_runs => {:exchange => nil, :depth_runs => :offers}).where(
                      ['snapshots.created_at > ? and snapshots.created_at < ?', start, stop])
                   .order('created_at desc')
      snapshot = snapshots.first

      data = {}
      snapshots.each do |snapshot|
        snapshot.exchange_runs.each do |ex_run|
          data[ex_run.exchange] ||= [ ex_run.exchange.name, [], [] ]

          if ex_run.depth_runs.count == 2
            # tofix: bid/ask detection
            o=ex_run.depth_runs.first
            op = o.best_offer ? o.best_offer.price : nil
            data[ex_run.exchange][1] << [o.created_at.to_i*1000, op]
            o=ex_run.depth_runs.last
            op = o.best_offer ? o.best_offer.price : nil
            data[ex_run.exchange][2] << [o.created_at.to_i*1000, op]
          end
        end
      end
      @chart_data = data.map{|k,v| v}

      @strategy_data = snapshots.map{|s| [s.created_at.to_i*1000,
                                          s.strategy.potential.amount.to_f] if s.strategy}
      @strategy_ids = snapshots.map{|s| s.strategy.id if s.strategy}
      @strategy_percentages = snapshots.map{|s| [s.created_at.to_i*1000,
                                                  s.strategy.profit_percentage.to_f] if s.strategy}

      if params[:strategy_id]
        @strategy = Strategy.find(params[:strategy_id])
      else
        @strategy = snapshot.strategy if snapshot
      end

      respond_to do |format|
        format.html # index.html.erb
        format.json do
          if @strategy
           render :json => {balance_in: {amount:@strategy.balance_in.amount,
                                         currency:@strategy.balance_in.currency},
                            potential: {amount:@strategy.potential.amount,
                                        currency:@strategy.potential.currency},
                            profit_percentage: @strategy.profit_percentage,
                            created_at: @strategy.created_at,
                            strategy_id: @strategy.id}
          else
           render :json => {}
          end
        end
      end
    end
  end

  def pairs
    @data = [ ["mtgox/abc", [[1, 4]]]]
    @pairs = Strategy.pair_spreads

  end
end
