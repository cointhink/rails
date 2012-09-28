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
end
