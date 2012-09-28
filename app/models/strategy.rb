class Strategy < ActiveRecord::Base
  # attr_accessible :title, :body
  has_many :trades, :dependent => :destroy

  def self.available_market_bids
    bids = []
    Market.all.each{|market| bids << available_bids(market)}
  end

  def self.available_bids(market)
    depths = market.depth_runs.last.depths
    bids = depths.bids.order("price desc")
    consume_depths(bids, market.btc)
  end

  def self.satisfied_bids
    run_ids = Market.all.map{|market| market.depth_runs.last.id}
    depths = Offer.where("depth_run_id in (?)", run_ids)

    asks = depths.joins(:in_balance).asks.order("balances.amount asc")
    bids = depths.joins(:out_balance).bids.order("balances.amount desc")
puts bids.explain
    bid = bids.first
    fee_percentage = bid.depth_run.market.fee_percentage
    remaining_factor = 1-(fee_percentage/100.0)
    bid_price_with_fee = bid.balance.amount*remaining_factor
    puts "Target price $#{bid_price_with_fee} ($#{bid.balance.amount} original, #{fee_percentage}% fee. #{remaining_factor})"
    matching_asks = asks.where('balances.amount < ?', bid_price_with_fee)
    action_asks = consume_depths(matching_asks, bid.balance)

    action = [bid, action_asks]
    [action] # single action strategy
  end

  def self.consume_depths(offers, money)
    puts "Buying the first #{money.amount}#{money.currency} from #{offers.size} offers"
    momentum = money.amount
    actions = []
    offers.each do |offer|
      if momentum > 0.00001 #floatingpoint
        quantity = [momentum / offer.balance.amount, offer.other_balance.amount].min
        momentum -= offer.balance.amount*quantity
        actions << [offer, quantity]
      end
    end
    actions
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
    puts strategy.trades.inspect
  end

  def self.total_since(time)
    trades = Strategy.where(["created_at > ?", time]).map do |s|
              [s.trades.first.balance_in.amount,
               s.trades.last.calculated_out]
            end
    trades.sum{|t| t.last - t.first}
  end
end
