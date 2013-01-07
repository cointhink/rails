class DashController < ApplicationController
  def chart
    hours = (params[:hours] || 8).to_i
    start = params[:start] ? Time.parse(params[:start]) : Time.now - hours.hours
    stop = start + hours.hours

    if stale?(Snapshot.latest)
      snapshots = Snapshot.includes(:exchange_runs => [:exchange, :depth_runs]).where(
                      ['snapshots.created_at > ? and snapshots.created_at < ?', start, stop])
                   .order('created_at desc')

      chart_data = {}
      snapshots.each do |snapshot|
        snapshot.exchange_runs.each do |ex_run|
          chart_data[ex_run.exchange] ||= [ ex_run.exchange.name, [], [] ]

          depth_runs = ex_run.depth_runs.includes(:best_offer).all
          if depth_runs.size == 2
            o=depth_runs.first # tofix: bid/ask detection
            op = o.best_offer ? o.best_offer.price : nil
            chart_data[ex_run.exchange][1] << [o.created_at.to_i*1000, op]
            o=depth_runs.last # tofix: bid/ask detection
            op = o.best_offer ? o.best_offer.price : nil
            chart_data[ex_run.exchange][2] << [o.created_at.to_i*1000, op]
          end
        end
      end
      @chart_data = chart_data.map{|k,v| v}

      @strategy_data = snapshots.map{|s| [s.created_at.to_i*1000,
                                          s.strategy.potential.amount.to_f] if s.strategy}
      @strategy_ids = snapshots.map{|s| s.strategy.id if s.strategy}
      @strategy_percentages = snapshots.map{|s| [s.created_at.to_i*1000,
                                                  s.strategy.profit_percentage.to_f] if s.strategy}

      if params[:strategy_id]
        @strategy = Strategy.find(params[:strategy_id])
      else
        @strategy = snapshots.first.strategy if snapshots.size > 0
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

  def fourohfour
  end
end
