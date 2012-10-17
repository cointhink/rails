class DashController < ApplicationController
  def chart
    time = 8.hours.ago
    exchanges = Market.internal.trading('btc','usd').map{|m| m.exchange}

    @chart_data = exchanges.map do |exchange|
      btcusd = exchange.markets.internal.trading('btc','usd')
      usdbtc = exchange.markets.internal.trading('usd','btc')
      [ exchange.name,
        btcusd.first.depth_runs.where("created_at > ?", time).
          map{|dr| o=dr.offers.order('price asc').last; [o.created_at.to_i*1000, o.price.to_f] if o},
        usdbtc.first.depth_runs.where("created_at > ?", time).
          map{|dr| o=dr.offers.order('price desc').last; [o.created_at.to_i*1000, o.price.to_f] if o},
      ]
    end

    strategies = Strategy.where(["created_at > ?", time])
    @strategy_data = strategies.map{|s| [s.created_at.to_i*1000, s.potential.amount.to_f] if s.potential}
    @strategy_ids = strategies.map{|s| s.id}

    if params[:strategy_id]
      @strategy = Strategy.find(params[:strategy_id])
    else
      @strategy = Strategy.last
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
