class Offer < ActiveRecord::Base
  attr_accessible :listed_at, :bidask, :price, :quantity
  validates :price, :quantity, :presence => true
  belongs_to :depth_run

  scope :asks, where(bidask: "ask")
  scope :bids, where(bidask: "bid")

  def balance(currency = nil)
    currency ||= market.to_currency
    currency_check!(currency)
    Balance.new(amount: price_calc(currency), currency: currency)
  end

  def balance_with_fee(currency = nil)
    balance(currency) * (1-market_fee)
  end

  def market_fee
    market.fee_percentage/100
  end

  private
  def price_calc(currency)
    if currency == market.from_currency
    elsif currency == market.to_currency
      price
    end
  end

  def fee_factor(currency)
    if currency == market.from_currency
      (1+market_fee)
    elsif currency == market.to_currency
      (1-market_fee)
    end
  end

  def market
    depth_run.market
  end

  def currency_check!(currency)
    if (currency != market.from_currency) && (currency != market.to_currency)
      raise "Invalid currency - #{currency} for market #{market.from_currency}/#{market.to_currency}"
    end
  end
end
