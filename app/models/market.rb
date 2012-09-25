class Market < ActiveRecord::Base
  attr_accessible :name
  has_many :tickers
  has_many :balances, :as => :balanceable
  has_many :trades

  # Class methods
  def self.pair_spreads
    pairs = Combinatorics.pairs(Market.all)
    askbids = pairs.map do |m|
      buy_for = m[0].last_ticker.lowest_ask_usd
      sell_for = m[1].last_ticker.highest_bid_usd

      buy_fee = buy_for*(m[0].fee_percentage/100.0)
      resultant_btc = (buy_for-buy_fee)/buy_for
      sell_fee = resultant_btc *sell_for*(m[1].fee_percentage/100.0)

      [m[0],
       buy_for,
       buy_fee,
       m[1],
       sell_for,
       sell_fee,
       sell_for - buy_for - buy_fee - sell_fee ]
    end
    askbids.sort{|a,b| b[6] <=> a[6]}
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
