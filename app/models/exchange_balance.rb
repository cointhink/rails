class ExchangeBalance < ActiveRecord::Base
  belongs_to :exchange
  attr_accessible :exchange
  has_many :balances, :as => :balanceable, :dependent => :destroy

  validates :exchange_id, :presence => true
end
