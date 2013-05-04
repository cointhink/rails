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

  def self.transfers(from_exchange, to_exchange, currency)
    where('from_exchange_id = ?', from_exchange.id).
    where('to_exchange_id = ?', to_exchange.id).
    where('from_currency = ? and to_currency = ?', currency, currency).
    order('fee_percentage asc')
  end

  def name
    if from_exchange != exchange
      from_exchange_name = "#{from_exchange.name}-"
    end
    if to_exchange != exchange
      to_exchange_name = "#{to_exchange.name}-"
    end
    "#{exchange.name} #{from_exchange_name}#{from_currency}/#{to_exchange_name}#{to_currency}"
  end

  def bidask(currency)
    # btc/usd is BID
    from_currency == currency ? "ask" : "bid"
  end

  def fee
    fee_percentage/100
  end

  def api
    "Markets::#{exchange.name.classify}".constantize.new(self)
  end

  def pair
    Market.where(["to_exchange_id = ? and from_exchange_id = ?",
           to_exchange_id, from_exchange_id]).
           where(["from_currency = ? and to_currency = ?",
                  to_currency, from_currency]).first
  end

  def last_ticker
    tickers.last
  end

  def depth_filter(data, currency)
    depth_run = depth_runs.create
    offers = api.offers(data, bidask(currency), currency)
    offers.map!{|o| o.merge({market_id:id})}
    ActiveRecord::Base.transaction do
      depth_run.offers.create(offers)
    end

    top_percentage = 25
    if bidask(currency) == "bid"
      best_offers = depth_run.offers.order('price desc')
      best_offer = best_offers.first
      ten_percent_offers = best_offers.where(['price > ?', best_offer.price*(1-(top_percentage/100.0))])
    elsif bidask(currency) == "ask"
      best_offers = depth_run.offers.order('price asc')
      best_offer = best_offers.first
      ten_percent_offers = best_offers.where(['price < ?', best_offer.price*(1+(top_percentage/100.0))])
    else
      raise "depth_filter failed, bad currency #{currency} for market #{self}"
    end

    cost = Balance.create({currency:currency, amount:ten_percent_offers.sum{|o| o.price*o.quantity}})
    puts "#{currency} #{self.from_currency}/#{self.to_currency} Best offer: #{"%0.5f"%best_offer.price} Cost: #{cost}"
    depth_run.update_attributes!({:best_offer => best_offer,
                                  :cost => cost})
    depth_run
  end

  def ticker
    tickers.last
  end

  def offers
    last_run = depth_runs.last
    last_run ? last_run.offers : []
  end
end
