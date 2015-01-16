class DashController < ApplicationController
  def chart
    @hours = (params[:hours] || 8).to_i
    start = params[:start] ? Time.parse(params[:start]) : Time.now - @hours.hours
    stop = start + @hours.hours

    @snapshots = Snapshot.between(start, stop)

    if params[:pair]
      if params[:pair].include?(':')
        @ac, @pc = params[:pair].split(':')
      else
        @ac = params[:pair][0,3]
        @pc = params[:pair][3,3]
      end
    else
      redirect_to '/arbitrage/btc:usd'
      return
    end

    if params[:strategy_id]
      @strategy = Strategy.find(params[:strategy_id])
    else
      if @snapshots.size > 0
        @strategy = @snapshots.first.strategies.for(@ac, @pc).first
      end
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
         render :json => {error: "not available"}
        end
      end
    end
  end

  def slider
    from_market = params[:pair][0,3]
    to_market = params[:pair][3,3]
    @exchanges = Exchange.with_markets(from_market, to_market)
  end

  def menu
    @snapshot = Snapshot.last || Snapshot.new
    @exchanges = []
    if @snapshot
      latest_exchanges = @snapshot.exchange_runs.map{|er| er.exchange}
      @exchanges = Exchange.with_markets('btc','usd').map do |m|
        e = {:exchange => m[:exchange], :cost => 0} #descriptive data
        if latest_exchanges.include?(m[:exchange])
          exchange_runs = @snapshot.exchange_runs.select{|er| er.exchange == m[:exchange]}.first
          e[:depth_runs] = exchange_runs.depth_runs.reduce({}){|m,dr| m[dr.market.bidask('usd')]=dr.cost;m}
          e[:cost] = e[:depth_runs].values.sum{|cost| cost.amount.to_f}
        end
        e
      end
      @exchanges.sort_by!{|e| e[:cost]}.reverse!
    end
    @news = Note.order('created_at desc').limit(7)
  end

  def fourohfour
    render :status => 404
  end
end
