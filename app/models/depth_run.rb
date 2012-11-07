class DepthRun < ActiveRecord::Base
  belongs_to :market
  belongs_to :exchange_run
  has_many :offers

  attr_accessible :exchange_run, :body

end
