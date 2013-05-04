class DashController < ApplicationController
  def chart
    @hours = (params[:hours] || 8).to_i
    start = params[:start] ? Time.parse(params[:start]) : Time.now - @hours.hours
    stop = start + @hours.hours

    @snapshots = Snapshot.includes(:exchange_runs => [:exchange, :depth_runs]).where(
                    ['snapshots.created_at > ? and snapshots.created_at < ?', start, stop])
                 .order('created_at desc')


    if params[:strategy_id]
      @strategy = Strategy.find(params[:strategy_id])
    else
      @strategy = @snapshots.first.strategy if @snapshots.size > 0
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json do
        if @strategy
         render :json => {balance_in: {amount:@strategy.balance_in.amount.round(2),
                                       currency:@strategy.balance_in.currency},
                          potential: {amount:@strategy.potential.amount.round(2),
                                      currency:@strategy.potential.currency},
                          profit_percentage: @strategy.profit_percentage.round(1),
                          created_at: @strategy.created_at,
                          strategy_id: @strategy.id}
        else
         render :json => {}
        end
      end
    end
  end

  def slider
    from_market = params[:pair][0,3]
    to_market = params[:pair][3,3]
    @exchanges = Exchange.with_markets(from_market, to_market)
  end

  def pairs
    @data = [ ["mtgox/abc", [[1, 4]]]]
    @pairs = Strategy.pair_spreads

  end

  def menu
    @snapshot = Snapshot.last
    latest_exchanges = @snapshot.exchange_runs.map{|er| er.exchange}
    @exchanges = Exchange.with_markets('btc','usd').map do |m|
      e = {:exchange => m[:exchange], :cost => 0} #descriptive data
      if latest_exchanges.include?(m[:exchange])
        exchange_runs = @snapshot.exchange_runs.select{|er| er.exchange == m[:exchange]}.first
        e[:depth_runs] = exchange_runs.depth_runs
        e[:cost] = e[:depth_runs].sum{|dr| dr.cost.amount.to_f}
      end
      e
    end
    logger.info @exchanges.map{|e| [e[:name], e[:cost]]}
    @exchanges.sort_by!{|e| e[:cost]}.reverse!
    logger.info @exchanges.map{|e| [e[:name], e[:cost]]}
  end

  def fourohfour
    render :status => 404
  end
end
