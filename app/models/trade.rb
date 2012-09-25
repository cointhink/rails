class Trade < ActiveRecord::Base
  belongs_to :market
  has_one :balance_in, :as => :balanceable, :class_name => :Balance
  has_one :balance_out, :as => :balanceable, :class_name => :Balance
  attr_accessible :executed, :expected_fee,
                  :expected_rate, :fee, :order_id, :rate,
                  :balance_in, :balance_out

  # if executed == false, these columns are valid
  # amount_in, expected_fee, expected_rate

  def calculated_out
    (amount_in - expected_fee) * expected_rate
  end
end
