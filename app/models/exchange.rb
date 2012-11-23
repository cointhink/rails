class Exchange < ActiveRecord::Base
  has_many :markets, :dependent => :destroy
  has_many :exchange_runs, :dependent => :destroy
  has_many :balances, :as => :balanceable, :dependent => :destroy
  attr_accessible :fee_percentage, :name, :country_code, :active,
                  :last_http_duration_ms

  scope :actives, where('active is true')

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
    best = Market.transfers(from_exchange, self, balance).first
    best ||  Exchange.find_by_name('btce').best_changer(Exchange.find_by_name('mtgox'), 'usd')
  end

end
