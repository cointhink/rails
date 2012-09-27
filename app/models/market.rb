class Market < ActiveRecord::Base
  attr_accessible :name, :fee_percentage
  has_many :tickers
  has_many :balances, :as => :balanceable
  has_many :trades
  has_many :depth_runs

  # Class methods
  def self.pair_spreads
    pairs = Combinatorics.pairs(Market.all)
    askbids = pairs.map do |m|
      buy_for = m[0].last_ticker.lowest_ask_usd
      sell_for = m[1].last_ticker.highest_bid_usd

      buy_fee = buy_for*(m[0].fee_percentage/100.0)
      resultant_btc = (buy_for-buy_fee)/buy_for
      sell_fee = resultant_btc*(m[1].fee_percentage/100.0)

      [m[0],
       buy_for,
       buy_fee,
       m[1],
       1/sell_for,
       sell_fee,
       sell_for - buy_for - buy_fee - sell_fee ]
    end
    askbids.sort{|a,b| b[6] <=> a[6]}
  end

  def usd
    balances.usd.last || balances.create({currency:"usd", amount: 0})
  end

  def btc
    balances.btc.last || balances.create({currency:"btc", amount: 0})
  end

  def last_ticker
    tickers.last
  end

  def api
    "Markets::#{name.classify}".constantize.new
  end

  def data_poll
    ticker_poll
    depth_poll
  end

  def ticker_poll
    attrs = api.ticker_poll
    tickers.create(attrs)
  end

  def depth_poll
    depth_data = api.depth_poll
    depth_run = depth_runs.create
    ActiveRecord::Base.transaction do
      depth_run.depths.create(depth_data["bids"])
      depth_run.depths.create(depth_data["asks"])
    end
  end
end
