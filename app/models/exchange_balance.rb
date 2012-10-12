class ExchangeBalance < ActiveRecord::Base
  belongs_to :strategy
  belongs_to :exchange
  has_many :balances, :as => :balanceable, :dependent => :destroy
  attr_accessible :exchange, :balances

  validates :exchange_id, :strategy_id, :presence => true
end
