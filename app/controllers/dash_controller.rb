class DashController < ApplicationController
  def chart
    time = 8.hours.ago
    exchanges = Market.internal.trading('btc','usd').map{|m| m.exchange}

    @chart_data = exchanges.map do |exchange|
      btcusd = exchange.markets.internal.trading('btc','usd')
      usdbtc = exchange.markets.internal.trading('usd','btc')
      [ exchange.name,
        btcusd.first.depth_runs.where("created_at > ?", time).
          map{|dr| o=dr.offers.order('price asc').last; [o.created_at.to_i*1000, o.price.to_f]},
        usdbtc.first.depth_runs.where("created_at > ?", time).
          map{|dr| o=dr.offers.order('price desc').last; [o.created_at.to_i*1000, o.price.to_f]},
      ]
    end

    strategies = Strategy.where(["created_at > ?", time])
    @strategy_data = strategies.map{|s| [s.created_at.to_i*1000, s.potential.amount.to_f]}
    @strategy_ids = strategies.map{|s| s.id}

    if params[:strategy_id]
      @strategy = Strategy.find(params[:strategy_id])
    else
      @strategy = Strategy.last
    end
  end

  def pairs
    @data = [ ["mtgox/abc", [[1, 4]]]]
    @pairs = Strategy.pair_spreads

  end
end
