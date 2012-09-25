class Strategy < ActiveRecord::Base
  # attr_accessible :title, :body
  has_many :trades

  def self.create_two_trades(pair)
    trade1 = pair[0].trades.create({amount_in:pair[1],
                                    expected_fee:pair[2],
                                    expected_rate:pair[1]})
    trade2 = pair[3].trades.create({amount_in:pair[4],
                                    expected_fee:pair[5],
                                    expected_rate:pair[4]})
    strategy = Strategy.create
    strategy.trades << trade1
    strategy.trades << trade2
  end
end
