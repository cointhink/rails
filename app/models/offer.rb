class Offer < ActiveRecord::Base
  attr_accessible :listed_at, :bidask, :price, :currency, :quantity

  belongs_to :depth_run

  scope :asks, where(bidask: "ask")
  scope :bids, where(bidask: "bid")

  def balance
    Balance.new(amount: price, currency: depth_run.market.right_currency)
  end

  def price_with_fee
    fee = depth_run.market.exchange.fee_percentage/100
    if bidask == 'ask'
      price*(1+fee)
    elsif bidask == 'bid'
      price*(1-fee)
    end
  end

  def cost(quantity=quantity)
    price*quantity
  end
end
