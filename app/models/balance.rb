class Balance < ActiveRecord::Base
  belongs_to :balanceable, :polymorphic => true
  attr_accessible :amount, :currency

  scope :usd, where(:currency => "usd")
  scope :btc, where(:currency => "btc")
end
