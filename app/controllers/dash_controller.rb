class DashController < ApplicationController
  def chart
    @data = Market.all.map do |market|
      [ market.name,
        market.tickers.map{|t| [t.created_at.to_i*1000, t.highest_bid_usd.to_f]},
        market.tickers.map{|t| [t.created_at.to_i*1000, t.highest_bid_usd.to_f]}]
    end
  end
end
