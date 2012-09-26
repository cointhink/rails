class DepthRun < ActiveRecord::Base
  belongs_to :market
  has_many :depths
  # attr_accessible :title, :body
end
