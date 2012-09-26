class Depth < ActiveRecord::Base
  belongs_to :depth_run
  attr_accessible :amount, :currency, :listed_at, :price, :quantity, :bidask

  scope :asks, where(bidask: "ask")
  scope :bids, where(bidask: "bid")
end
