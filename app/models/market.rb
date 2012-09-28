class Market < ActiveRecord::Base
  attr_accessible :left_currency, :right_currency
  belongs_to :exchange
  has_many :tickers
  has_many :balances, :as => :balanceable
  has_many :trades
  has_many :depth_runs

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
    "Markets::#{exchange.name.classify}".constantize.new
  end

  def data_poll
    ticker_poll
    depth_data = depth_poll
    [exchange.name,
     "bid count: #{depth_data["bids"].size}",
     "bid max price: #{depth_data["bids"].max{|b| b[:price].to_i}}",
     depth_data["asks"].size]
  end

  def ticker_poll
    attrs = api.ticker_poll
    tickers.create(attrs)
  end

  def depth_poll
    depth_data = api.depth_poll
    depth_run = depth_runs.create
    ActiveRecord::Base.transaction do
      depth_run.offers.create(depth_data["bids"])
      depth_run.offers.create(depth_data["asks"])
    end
    depth_data
  end
end
