class DashController < ApplicationController
  def chart
    hours = params[:duration] ? params[:duration].to_i : 8
    start = params[:start] ? Time.parse(params[:start]) : Time.now - hours.hours
    stop = start + hours.hours
    snapshots = Snapshot.where(
                    ['created_at > ? and created_at < ?', start, stop])
                 .order('created_at desc')
    snapshot = snapshots.last
    exchanges = snapshot ? snapshot.exchanges : []

    @chart_data = exchanges.map do |exchange|
      data = [ exchange.name, [], [] ]
      er_shots = snapshots.map do |snapshot|
        er = snapshot.exchange_runs.find_by_exchange_id(exchange.id)
        if er
          er.depth_runs
        else
          []
        end
      end
      er_shots.map do |drs|
        if drs.size > 0
          data[1] += drs.map{|ss| o=drs.first.offers.order('price asc').last;
                               [o.created_at.to_i*1000, o.price.to_f] if o}
          data[2] += drs.map{|ss| o=drs.last.offers.order('price desc').last;
                             [o.created_at.to_i*1000, o.price.to_f] if o}

        end
      end
      data
    end

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
      format.json { render :json => {balance_in: {amount:@strategy.balance_in.amount,
                                                  currency:@strategy.balance_in.currency},
                                     potential: {amount:@strategy.potential.amount,
                                                 currency:@strategy.potential.currency},
                                     profit_percentage: @strategy.profit_percentage,
                                     created_at: @strategy.created_at,
                                     strategy_id: @strategy.id}}
    end
  end

  def pairs
    @data = [ ["mtgox/abc", [[1, 4]]]]
    @pairs = Strategy.pair_spreads

  end
end
