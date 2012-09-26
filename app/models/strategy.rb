class Strategy < ActiveRecord::Base
  # attr_accessible :title, :body
  has_many :trades, :dependent => :destroy

  def self.profitable_pairs_asks
    # filter for asks with matching bids, price only
    profitable_pairs = []
    Market.all.permutation(2) do |buy_market, sell_market|
      asks = buy_market.depth_runs.last.depths.asks.order("price desc")
      bids = sell_market.depth_runs.last.depths.bids.order("price asc")

      max_bid = bids.maximum(:price)
      max_bid_after_fee = max_bid*(1-(buy_market.fee_percentage/100))
      profitable_asks = asks.where("price < ?", max_bid_after_fee)
      if profitable_asks.count > 0
        profitable_pairs << [buy_market, profitable_asks, sell_market, []]
      end
    end
    profitable_pairs
  end

  def self.profitable_bids(profitable_asks)
        max_ask = profitable_asks.last.price
        eligible_bids = bids.where("price > ?", max_ask*(1-(sell_market.fee_percentage/100)))
        profitable_bids.each{|b| puts "bid: $#{b.price} #{b.quantity}btc =$#{b.momentum} "}
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
