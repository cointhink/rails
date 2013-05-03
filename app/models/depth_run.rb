class DepthRun < ActiveRecord::Base
  belongs_to :market
  belongs_to :exchange_run
  belongs_to :best_offer, :class_name => "Offer"
  belongs_to :cost, :class_name=>"Balance"
  has_many :offers, :dependent => :destroy

  attr_accessible :exchange_run, :best_offer, :cost

end
