class Ticker < ActiveRecord::Base
  belongs_to :market
  attr_accessible :hightest_bid_usd, :lowest_ask_usd
end
