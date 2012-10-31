class Trade < ActiveRecord::Base
  belongs_to :balance_in, :class_name => :Balance, :dependent => :destroy
  belongs_to :balance_out, :class_name => :Balance, :dependent => :destroy
  belongs_to :offer
  belongs_to :stage
  attr_accessible :executed, :order_id, :fee, :rate,
                  :balance_in, :balance_out, :offer,
                  :expected_fee

  # if executed == false, these columns are valid
  # amount_in, expected_fee, expected_rate

  def calculated_out
    amount = offer.cost(balance_in)
    amount*(1-offer.market_fee)
  end
end
