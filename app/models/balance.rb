class Balance < ActiveRecord::Base
  belongs_to :market
  attr_accessible :amount, :currency

  scope :usd, where(:currency => "usd")
  scope :btc, where(:currency => "btc")
end
