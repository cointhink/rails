class Market < ActiveRecord::Base
  attr_accessible :name
  has_many :tickers
  has_many :balances

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
end
