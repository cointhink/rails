class DashController < ApplicationController
  def chart
    @data = Market.all.map do |market|
      [ market.name,
        market.tickers.where("created_at > ?", 12.hours.ago).map{|t| [t.created_at.to_i*1000, t.highest_bid_usd.to_f]},
        market.tickers.where("created_at > ?", 12.hours.ago).map{|t| [t.created_at.to_i*1000, t.lowest_ask_usd.to_f]}]
    end

    @best_pair = Market.pair_spreads.first

    @last_mtgox = Market.first.last_ticker
    @last_bitstamp = Market.last.last_ticker
  end
end
