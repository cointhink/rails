class Offer < ActiveRecord::Base
  belongs_to :depth_run
  belongs_to :in_balance, :class_name => :Balance
  belongs_to :out_balance, :class_name => :Balance
  attr_accessible :listed_at, :bidask, :in_balance_attributes, :out_balance_attributes
  accepts_nested_attributes_for :in_balance, :out_balance

  scope :asks, where(bidask: "ask")
  scope :bids, where(bidask: "bid")

  def momentum
    in_balance.amount*out_balance.amount
  end
end
