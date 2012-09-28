class Offer < ActiveRecord::Base
  attr_accessible :listed_at, :bidask, :balance_attributes, :currency, :quantity

  belongs_to :depth_run
  belongs_to :balance
  accepts_nested_attributes_for :balance

  scope :asks, where(bidask: "ask")
  scope :bids, where(bidask: "bid")

  def momentum
    in_balance.amount*out_balance.amount
  end
end
