class Trade < ActiveRecord::Base
  belongs_to :market
  belongs_to :balance_in, :class_name => :Balance
  belongs_to :balance_out, :class_name => :Balance
  attr_accessible :executed, :expected_fee,
                  :expected_rate, :fee, :order_id, :rate,
                  :balance_in, :balance_out

  # if executed == false, these columns are valid
  # amount_in, expected_fee, expected_rate

  def calculated_out
    (balance_in.amount - expected_fee) * 1/expected_rate
  end
end
