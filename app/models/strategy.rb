class Strategy < ActiveRecord::Base
  belongs_to :balance_in, :class_name => :Balance, :dependent => :destroy
  belongs_to :balance_out, :class_name => :Balance, :dependent => :destroy
  belongs_to :potential, :class_name => :Balance, :dependent => :destroy

  # attr_accessible :title, :body
  has_many :trades, :dependent => :destroy

  # total opportunity
  def self.opportunity(ask_markets, bid_markets)
    # find all asks less than bids, fee adjusted
    # assume unlimited buying funds

    puts "Ask Markets: #{ask_markets.map{|m| "#{m.exchange.name} #{m.from_currency}/#{m.to_currency}"}.join(', ')}"
    puts "Bid Markets: #{bid_markets.map{|m| "#{m.exchange.name} #{m.from_currency}/#{m.to_currency}"}.join(', ')}"

    asks = ask_markets.each{|market| market.offers.order("price asc")}.flatten
    bids = bid_markets.each{|market| market.offers.order("price desc")}.flatten

    actions = clearing_offers(bids, asks)

    strategy = Strategy.create
    puts "Analyzing #{actions.size} trade groups"
    market_totals = {}
    actions.each do |action|
      ask = action[0]
      btc_spent = action[1]
      buys = action[2]
      market = market_totals[ask.depth_run.market.exchange.name] ||= Hash.new(0)
      market[:usd] += ask.cost_with_fee(btc_spent)

      # even more crap
      strategy.trades << Trade.new(balance_in: Balance.make_usd(ask.cost_with_fee(btc_spent)),
                                   balance_out: Balance.make_btc(btc_spent),
                                   market: ask.depth_run.market,
                                   expected_fee: ask.depth_run.market.exchange.fee_percentage,
                                   expected_rate: ask.price_with_fee)

      buys.each do |bid|
        bm = market_totals[bid[:offer].depth_run.market.exchange.name] ||= Hash.new(0)
        bm[:btc] += bid[:quantity]
        strategy.trades << Trade.new(balance_in: Balance.make_btc(bid[:quantity]),
                                     balance_out: Balance.make_usd(bid[:offer].cost_with_fee(bid[:quantity])),
                                     market: bid[:offer].depth_run.market,
                                     expected_fee: bid[:offer].depth_run.market.exchange.fee_percentage,
                                     expected_rate: bid[:offer].price)
      end
    end
    strategy.balance_in = strategy.balance_in_calc
    strategy.balance_out = strategy.balance_out_calc
    strategy.potential = strategy.balance_out - strategy.balance_in
    strategy.save

    puts "#{strategy.trades.count} actions. Investment #{strategy.balance_in} Profit #{strategy.potential}"
    market_totals.each {|k,v| puts "#{k} spends $#{"%0.2f"%v[:usd]} #{"%0.5f"%v[:btc]}btc"}
  end

  def self.best_bid(cash)
    depths = DepthRun.all_offers

    asks = depths.asks.order("price asc")
    bids = depths.bids.order("price desc")

    bid = bids.first

    fee_percentage = bid.depth_run.market.exchange.fee_percentage
    remaining_factor = 1-(fee_percentage/100.0)
    bid_after_fee = bid.balance*remaining_factor
    puts "Finding asks above #{bid_after_fee.amount}#{bid_after_fee.currency} (#{bid.balance.amount}#{bid.balance.currency} original, #{fee_percentage}% fee)"
    matching_asks = asks.where('price < ?', bid_after_fee.amount)
    action_asks = consume_offers(matching_asks, cash)

    action = [bid, action_asks]
    [action] # single action strategy
  end

  def self.clearing_offers(bids, asks)
    best_bid_price = bids.first.price_with_fee
    usd_in_check = Balance.make_usd(0)
    usd_out_check = Balance.make_usd(0)
    profit_check = Balance.make_usd(0)
    actions = []
    asks.each_with_index do |ask, i|
      print "#{i}. " if i%100==0 && i > 0
      if best_bid_price > ask.price_with_fee

        good_bids = bids.select{|b| b.price_with_fee > ask.price_with_fee && b.quantity > 0}
        puts "Profitable bid count #{good_bids.size}"
        bid_worksheet = consume_offers(good_bids, Balance.make_btc(ask.quantity))
        puts "#{ask.depth_run.market.exchange.name} ask $#{ask.price_with_fee} (orig. $#{ask.price}) x#{"%0.5f"%ask.quantity} $#{ask.cost_with_fee}"
        btc_in = 0
        usd_in = Balance.make_usd(0)
        usd_out = Balance.make_usd(0)
        bid_worksheet.each do |bw|
          puts "  #{bw[:offer].depth_run.market.exchange.name} bid ##{bw[:offer].id} $#{"%0.2f"%bw[:offer].price_with_fee} (orig. $#{"%0.2f"%bw[:offer].price}) x#{"%0.5f"%bw[:offer].quantity}btc (orig #{"%0.5f"%bw[:offer].quantity_with_fee}) qty_to_buy #{"%0.5f"%bw[:quantity]}btc earned: #{bw[:spent]-(ask.price_with_fee * bw[:quantity])}"
          btc_in +=  bw[:quantity]
          usd_out += bw[:spent]
        end
        usd_in = ask.price_with_fee * btc_in
        mini_profit = usd_out - usd_in
        puts "spent #{"%0.2f"%usd_in} left. received #{usd_out}. profit #{mini_profit}"
        profit_check += mini_profit
        usd_in_check += usd_in
        usd_out_check += usd_out
        actions << [ask, btc_in, bid_worksheet]
      end
    end
    puts
    puts "usd in check: #{usd_in_check} usd out check: #{usd_out_check} profit check: #{profit_check}"
    actions
  end

  def self.consume_offers(offers, money)
    puts "Buying the first #{money} from #{offers.size} offers"
    remaining = money.dup
    actions = []
    offers.each do |offer|
      if remaining > 0.00001 #floatingpoint
        if offer.bidask == 'ask'
          price = offer.balance_with_fee
          quantity_to_buy = [remaining / price, offer.quantity].min
          spent = price*quantity_to_buy
          remaining -= spent
        elsif offer.bidask == 'bid'
          quantity_to_buy = [offer.quantity_with_fee, remaining.amount].min
          remaining -= quantity_to_buy
          spent = offer.balance_with_fee*quantity_to_buy
        end
        if quantity_to_buy > 0.00001
          actions << {offer: offer, quantity: quantity_to_buy,
                      spent: spent }
        end
      end
    end
    actions
  end

  def self.pair_spreads
    pairs = Combinatorics.pairs(Market.all)
    askbids = pairs.map do |m|
      buy_for = m[0].last_ticker.lowest_ask_usd
      sell_for = m[1].last_ticker.highest_bid_usd

      buy_fee = buy_for*(m[0].exchange.fee_percentage/100.0)
      resultant_btc = (buy_for-buy_fee)/buy_for
      sell_fee = resultant_btc*(m[1].exchange.fee_percentage/100.0)

      [m[0],
       buy_for,
       buy_fee,
       m[1],
       1/sell_for,
       sell_fee,
       sell_for - buy_for - buy_fee - sell_fee ]
    end
    askbids.sort{|a,b| b[6] <=> a[6]}
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

  def self.potential_since(time)
    trades = Strategy.where(["created_at > ?", time]).sum(&:potential)
  end

  def balance_in_calc
    trades.reduce(Balance.make_usd(0)) do |total, trade|
      trade.balance_in.usd? ? total + trade.balance_in : total
    end
  end

  def balance_out_calc
    trades.reduce(Balance.make_usd(0)) do |total, trade|
      trade.balance_out.usd? ? total + trade.balance_out : total
    end
  end
end
