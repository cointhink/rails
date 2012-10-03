class DashController < ApplicationController
  def chart
    time = 8.hours.ago
    @data = Market.all.map do |market|
      [ market.exchange.name,
        market.tickers.where("created_at > ?", time).map{|t| [t.created_at.to_i*1000, t.highest_bid_usd.to_f]},
        market.tickers.where("created_at > ?", time).map{|t| [t.created_at.to_i*1000, t.lowest_ask_usd.to_f]}]
    end

    @strategies = Strategy.where(["created_at > ?", time]).map{|s| [s.created_at.to_i*1000, s.potential.amount.to_f]}
    @strategy = Strategy.last
  end

  def pairs
    @data = [ ["mtgox/abc", [[1, 4]]]]
    @pairs = Strategy.pair_spreads

  end
end
