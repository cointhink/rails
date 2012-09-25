class Strategy < ActiveRecord::Base
  # attr_accessible :title, :body
  has_many :trades

  def self.create_two_trades(pair)
    t1_in = Balance.create(amount: pair[1], currency: 'usd')
    t1_out = Balance.create(currency: 'btc')
    trade1 = pair[0].trades.create({balance_in:t1_in,
                                    balance_out:t1_out,
                                    expected_fee:pair[2],
                                    expected_rate:pair[1]})

    t2_in = Balance.create(amount: pair[4], currency: 'btc')
    t2_out = Balance.create(currency: 'usd')
    trade2 = pair[3].trades.create({balance_in: t2_in,
                                    balance_out: t2_out,
                                    expected_fee:pair[5],
                                    expected_rate:pair[4]})
    strategy = Strategy.create
    strategy.trades << trade1
    strategy.trades << trade2
  end
end
