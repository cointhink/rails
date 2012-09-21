class DashController < ApplicationController
  def chart
    @data = Market.where("created_at > ?", 1.day.ago).map do |market|
      [ market.name,
        market.tickers.map{|t| [t.created_at.to_i*1000, t.highest_bid_usd.to_f]},
        market.tickers.map{|t| [t.created_at.to_i*1000, t.lowest_ask_usd.to_f]}]
    end

    @last_mtgox = Market.first.last_ticker
    @last_bitstamp = Market.last.last_ticker
  end
end
