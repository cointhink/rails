class Offer < ActiveRecord::Base
  attr_accessible :listed_at, :bidask, :price, :currency, :quantity

  belongs_to :depth_run

  scope :asks, where(bidask: "ask")
  scope :bids, where(bidask: "bid")

  def balance
    Balance.new(amount: price, currency: depth_run.market.right_currency)
  end

  def balance_with_fee
    Balance.new(amount: price_with_fee, currency: depth_run.market.right_currency)
  end

  def price_with_fee
    price * fee_factor
  end

  def quantity_with_fee
    quantity / quantity_fee_factor
  end

  def fee
    depth_run.market.exchange.fee_percentage/100
  end

  def fee_factor
    if bidask == 'ask'
      (1+fee)
    elsif bidask == 'bid'
      (1-fee)
    end
  end

  def quantity_fee_factor
    if bidask == 'ask'
      (1-fee)
    elsif bidask == 'bid'
      (1+fee)
    end
  end

  def cost_with_fee(quantity=quantity)
    price_with_fee*quantity
  end
end
