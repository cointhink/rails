class Offer < ActiveRecord::Base
  attr_accessible :listed_at, :bidask, :price, :currency, :quantity

  belongs_to :depth_run

  scope :asks, where(bidask: "ask")
  scope :bids, where(bidask: "bid")

  def balance
    Balance.new(amount: price, currency: depth_run.market.right_currency)
  end

  def cost(quantity=quantity)
    price*quantity
  end
end
