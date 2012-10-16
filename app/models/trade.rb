class Trade < ActiveRecord::Base
  belongs_to :market
  belongs_to :balance_in, :class_name => :Balance, :dependent => :destroy
  belongs_to :balance_out, :class_name => :Balance, :dependent => :destroy
  attr_accessible :executed, :expected_fee,
                  :expected_rate, :fee, :order_id, :rate,
                  :balance_in, :balance_out, :market

  # if executed == false, these columns are valid
  # amount_in, expected_fee, expected_rate

  def calculated_out
    if balance_in.currency == market.to_currency
      Balance.new(amount:balance_in.amount, currency:market.from_currency) / expected_rate
    elsif balance_in.currency == market.from_currency
      Balance.new(amount:balance_in.amount, currency:market.to_currency) * expected_rate
    end
  end
end
