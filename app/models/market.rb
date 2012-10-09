class Market < ActiveRecord::Base
  attr_accessible :from_exchange, :from_currency,
                  :to_exchange, :to_currency, :fee_percentage, :delay_ms
  belongs_to :from_exchange, :class_name => :Exchange
  belongs_to :to_exchange, :class_name => :Exchange
  belongs_to :exchange
  has_many :tickers
  has_many :trades
  has_many :depth_runs

  def self.trading(from_currency, to_currency)
    Market.where(["to_exchange_id = from_exchange_id"]).
           where(["from_currency = ? and to_currency = ?",
                  from_currency, to_currency])
  end

  def last_ticker
    tickers.last
  end

  def data_poll
    ticker_poll
    depth_data = depth_poll
    [exchange.name,
     "bid count: #{depth_data["bids"].size}",
     "bid max price: #{depth_data["bids"].sort{|b| b[:price].to_i}[0,3]}",
     "ask count: #{depth_data["asks"].size}"]
  end

  def ticker_poll
    attrs = exchange.api.ticker_poll
    tickers.create(attrs)
  end

  def depth_poll
    depth_data = exchange.api.depth_poll
    depth_run = depth_runs.create
    ActiveRecord::Base.transaction do
      depth_run.offers.create(depth_data["bids"])
      depth_run.offers.create(depth_data["asks"])
    end
    depth_data
  end

  def ticker
    tickers.last
  end

  def offers
    depth_runs.last.offers
  end
end
