class Market < ActiveRecord::Base
  attr_accessible :from_exchange, :from_currency,
                  :to_exchange, :to_currency, :fee_percentage, :delay_ms
  belongs_to :from_exchange, :class_name => :Exchange
  belongs_to :to_exchange, :class_name => :Exchange
  belongs_to :exchange
  has_many :tickers
  has_many :trades
  has_many :depth_runs

  scope :internal, where("to_exchange_id = from_exchange_id")
  scope :trading, lambda { |from_currency, to_currency|
                    where(["from_currency = ? and to_currency = ?",
                           from_currency, to_currency]) }
  def api
    "Markets::#{exchange.name.classify}".constantize.new(self)
  end

  def last_ticker
    tickers.last
  end

  def depth_filter(data)
    depth_run = depth_runs.create
    offers = api.offers(data)
    ActiveRecord::Base.transaction do
      depth_run.offers.create(offers)
    end
  end

  def ticker
    tickers.last
  end

  def offers
    last_run = depth_runs.last
    last_run ? last_run.offers : []
  end
end
