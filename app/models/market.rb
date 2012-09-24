class Market < ActiveRecord::Base
  attr_accessible :name
  has_many :tickers
  has_many :balances

  # Class methods
  def self.pair_spreads
    pairs = Combinatorics.pairs(Market.all)
    askbids = pairs.map do |m|
      left_last = m[0].last_ticker
      right_last = m[1].last_ticker
      [m[0].name,
       left_last.lowest_ask_usd,
       m[1].name,
       right_last.highest_bid_usd,
       left_last.lowest_ask_usd - right_last.highest_bid_usd]
    end
    askbids.sort{|e| e[4]}.reverse
  end

  def usd_balance
    last = balances.usd.last
    last ? last.amount : 0
  end

  def btc_balance
    last = balances.btc.last
    last ? last.amount : 0
  end

  def last_ticker
    tickers.last
  end

  def api
    "Markets::#{name.classify}".constantize.new
  end

  def data_poll
    attrs = api.data_poll
    tickers.create(attrs)
  end
end
