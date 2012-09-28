class DepthRun < ActiveRecord::Base
  belongs_to :market
  has_many :offers
  # attr_accessible :title, :body
end
