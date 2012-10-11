class Balance < ActiveRecord::Base
  belongs_to :balanceable, :polymorphic => true
  attr_accessible :amount, :currency
  validates :amount, :currency, :presence => true

  scope :usd, where(:currency => "usd")
  scope :btc, where(:currency => "btc")

  def self.make_btc(amount)
    Balance.new(amount:amount,currency:'btc')
  end

  def self.make_usd(amount)
    Balance.new(amount:amount,currency:'usd')
  end

  def <(num)
    amount<value(num)
  end

  def >(num)
    amount>value(num)
  end

  def *(num)
    Balance.new(amount: amount*value(num), currency: currency)
  end

  def /(num)
    Balance.new(amount: amount/value(num), currency: currency)
  end

  def -(num)
    Balance.new(amount: amount-value(num), currency: currency)
  end

  def +(num)
    Balance.new(amount: amount+value(num), currency: currency)
  end

  def min(num)
    answer = amount < value(num) ? self : num
    if answer.is_a?(Balance)
      answer
    else
      Balance.new(amount: answer, currency: currency)
    end
  end

  def value(num)
    if num.is_a?(Balance)
      currency_check!(num)
      num.amount
    else
      num
    end
  end

  def currency_check!(num)
    raise "Currency #{currency} != #{num.currency}" if currency != num.currency
  end

  def to_s
    decimal = currency == 'usd' ? 2 : 5
    format = "%0.#{decimal}f"
    "#{format%amount}#{currency}"
  end

  def usd?
    currency == 'usd'
  end

  def btc?
    currency == 'btc'
  end
end
