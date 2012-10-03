class Balance < ActiveRecord::Base
  belongs_to :balanceable, :polymorphic => true
  attr_accessible :amount, :currency

  scope :usd, where(:currency => "usd")
  scope :btc, where(:currency => "btc")

  def self.make_btc(amount)
    Balance.new(amount:amount,currency:'btc')
  end

  def self.make_usd(amount)
    Balance.new(amount:amount,currency:'usd')
  end

  def *(num)
    if num.is_a?(Balance)
      currency_check!(num)
      quantity = num.amount
    else
      quantity = num
    end
    Balance.new(amount: amount*quantity, currency: currency)
  end

  def -(num)
    currency_check!(num)
    Balance.new(amount: amount-num.amount, currency: currency)
  end

  def +(num)
    currency_check!(num)
    Balance.new(amount: amount+num.amount, currency: currency)
  end

  def currency_check!(balance)
    raise "Incompatible currencies - #{currency}/#{num.currency}" if currency != num.currency
  end
end
