class Trade < ActiveRecord::Base
  belongs_to :market
  attr_accessible :amount_in, :amount_out, :executed, :expected_fee, :expected_rate, :fee, :order_id, :rate

  # if executed == false, these columns are valid
  # amount_in, expected_fee, expected_rate
end
