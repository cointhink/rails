class Strategy < ActiveRecord::Base
  # attr_accessible :title, :body
  has_many :trades
end
