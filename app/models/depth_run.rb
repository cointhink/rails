class DepthRun < ActiveRecord::Base
  belongs_to :market
  belongs_to :exchange_run
  belongs_to :best_offer, :class_name => "Offer"
  has_many :offers, :dependent => :destroy

  attr_accessible :exchange_run, :best_price

end
