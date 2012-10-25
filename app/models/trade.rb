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
    # expected_rate is always in USD
    if market.to_currency == 'usd'
      amount = Balance.new(amount:balance_in.amount,
                  currency:market.to_currency) * expected_rate
    else
      amount = Balance.new(amount:balance_in.amount,
                  currency:market.to_currency) / expected_rate
    end
    amount*(1-expected_fee/100)
  end
end
