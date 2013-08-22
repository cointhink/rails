class Exchange < ActiveRecord::Base
  has_many :markets, :dependent => :destroy
  has_many :exchange_runs, :dependent => :destroy
  has_many :balances, :as => :balanceable, :dependent => :destroy
  has_many :notes, :as => :notable, :dependent => :destroy
  attr_accessible :fee_percentage, :name, :country_code, :active,
                  :last_http_duration_ms, :display_name

  scope :actives, where('active is true')

  extend FriendlyId
  friendly_id :name, use: :slugged

  def self.with_markets(from_currency, to_currency)
    actives.map do |exchange|
      bid_market = exchange.markets.internal.trading(from_currency, to_currency).first
      if bid_market
        { exchange:exchange, bid_market:bid_market, ask_market: bid_market.pair}
      end
    end.select{|t| t}
  end

  def api
    @api ||= "Exchanges::#{name.classify}".constantize.new
  end

  def usd
    balances.usd.last
  end

  def btc
    balances.btc.last
  end

  def best_changer(from_exchange, balance)
    Market.transfers(from_exchange, self, balance).first
  end

end
