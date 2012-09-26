class Depth < ActiveRecord::Base
  belongs_to :market
  attr_accessible :amount, :currency, :listed_at, :price, :quantity, :bidask
end
