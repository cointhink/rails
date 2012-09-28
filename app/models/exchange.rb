class Exchange < ActiveRecord::Base
  has_many :markets, :dependent => :destroy
  attr_accessible :fee_percentage, :name
end
