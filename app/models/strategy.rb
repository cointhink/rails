class Strategy < ActiveRecord::Base
  # attr_accessible :title, :body
  has_many :trades, :dependent => :destroy

  def self.satisfied_bids

    runs = Market.all.map{|market| market.depth_runs.last.id}
    depths = Depth.where("depth_run_id in (?)", runs)

    asks = depths.asks.order("price desc")
    bids = depths.bids.order("price asc")

    #max_bid = bids.maximum(:price)
    #max_bid_after_fee = max_bid*(1-(buy_market.fee_percentage/100))
    #profitable_asks = asks.where("price < ?", max_bid_after_fee)
    #if profitable_asks.count > 0
    #  profitable_pairs << [buy_market, profitable_asks, sell_market, []]
    #end
  end

  def self.create_two_trades(pair)
    t1_in = Balance.create(amount: pair[1], currency: 'usd')
    t1_out = Balance.create(currency: 'btc')
    trade1 = pair[0].trades.create({balance_in:t1_in,
                                    balance_out:t1_out,
                                    expected_fee:pair[2],
                                    expected_rate:pair[1]})

    t2_in = Balance.create(amount: trade1.calculated_out, currency: 'btc')
    t2_out = Balance.create(currency: 'usd')
    trade2 = pair[3].trades.create({balance_in: t2_in,
                                    balance_out: t2_out,
                                    expected_fee:pair[5],
                                    expected_rate:pair[4]})
    strategy = Strategy.create
    strategy.trades << trade1
    strategy.trades << trade2
  end

  def self.total_since(time)
    trades = Strategy.where(["created_at > ?", time]).map do |s|
              [s.trades.first.balance_in.amount,
               s.trades.last.calculated_out]
            end
    trades.sum{|t| t.last - t.first}
  end
end
