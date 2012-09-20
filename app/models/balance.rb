class Balance < ActiveRecord::Base
  belongs_to :market
  attr_accessible :amount, :currency
end
