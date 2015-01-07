class Offer < ActiveRecord::Base
  attr_accessible :listed_at, :bidask, :price, :quantity, :currency,
                  :market_id, :market
  validates :price, :quantity, :presence => true
  belongs_to :depth_run
  belongs_to :market

  scope :asks, where(bidask: "ask")
  scope :bids, where(bidask: "bid")
  scope :trades, lambda {|from_currency, to_currency| joins(:market).where(['markets.from_currency = ? and markets.to_currency = ?', from_currency, to_currency])}

  def rate(currency = market.from_currency)
    currency_check!(currency)
    Balance.new(amount: price_calc(currency), currency: currency)
  end

  def cost(amount = nil)
    if amount
      currency_check!(amount.currency)
    else
      amount = Balance.new(amount: quantity, currency: market.to_currency)
    end
    if amount.currency == market.from_currency
      currency = market.to_currency
    else
      currency = market.from_currency
    end
    rate(currency)*amount.amount
  end

  def spend!(amount)
    raise "Invalid currency " if amount.currency != market.from_currency
    spend = amount.min(quantity)
    self.quantity -= spend.amount
    spend
  end

  def market_fee
    market.fee_percentage/100
  end

  def fee_factor(currency)
    if currency == market.from_currency
      (1+market_fee)
    elsif currency == market.to_currency
      (1-market_fee)
    else
      raise "Invalid currency - #{currency} is not #{market.from_currency} or #{market.to_currency}"
    end
  end

  private
  def price_calc(currency)
    if currency == self.currency
      price
    else
      1/price
    end
  end

  def currency_check!(currency)
    if (currency != market.from_currency) && (currency != market.to_currency)
      raise "Invalid currency - #{currency} for market #{market.from_currency}/#{market.to_currency}"
    end
  end

  def quantity_check!(qty)
    raise "Invalid quantity. #{qty} excceds quantity #{quantity}" if qty > quantity
  end
end
