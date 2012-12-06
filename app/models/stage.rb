class Stage < ActiveRecord::Base
  belongs_to :balance_in, :class_name => :Balance, :dependent => :destroy
  belongs_to :balance_out, :class_name => :Balance, :dependent => :destroy
  belongs_to :potential, :class_name => :Balance, :dependent => :destroy
  belongs_to :strategy

  has_many :trades

  attr_accessible :name, :sequence, :children_concurrent, :potential, :balance_in

  acts_as_tree order: "sequence"

  def buy
    buys.first
  end

  def buys
    trades.select{|t| t.balance_in.usd?}
  end

  def sells
    trades.select{|t| t.balance_in.btc?}
  end

  def balance_in_calc
    buys.reduce(Balance.make_usd(0)) do |total, trade|
      total + trade.balance_in
    end
  end

  def balance_usd_out
    sells.reduce(Balance.make_usd(0)) do |total, trade|
      total + trade.calculated_out
    end
  end

  def profit_percentage
    if balance_in && balance_in > 0
      (potential/balance_in).amount*100
    else
      0
    end
  end

  def profit(sell)
    buyo = buy.offer
    sello = sell.offer
    amount = sell.balance_in
    (sello.rate('usd')*sello.fee_factor('usd') -
       buyo.rate('usd')*buyo.fee_factor('usd'))*
    amount.amount
  end
end
