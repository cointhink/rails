class Strategy < ActiveRecord::Base
  # attr_accessible :title, :body
  has_many :trades, :dependent => :destroy

  # total opportunity
  def self.opportunity(markets)
    # find all asks less than bids, fee adjusted
    # assume unlimited buying funds

    offers = DepthRun.all_offers(markets)
    puts "Gathering info from #{markets.map{|m| "#{m.exchange.name} #{m.left_currency}/#{m.right_currency}"}.join(', ')}"

    asks = offers.asks.order("price asc")
    bids = offers.bids.order("price desc")

    actions = clearing_offers(bids, asks)

    market_totals = {}
    profit = actions.sum do |action|
      ask = action.first
      buys = action.last
      market = market_totals[ask.depth_run.market.exchange.name] ||= Hash.new(0)
      market[:usd] += ask.cost
      buys.each do |bid|
        bm = market_totals[bid[:offer].depth_run.market.exchange.name] ||= Hash.new(0)
        bm[:btc] += bid[:quantity]
      end
      buys.sum{|bid| bid[:offer].cost(bid[:quantity])} - ask.cost
    end
    investment = actions.sum {|action| action.first.cost }
    puts "#{actions.size} actions. Investment $#{"%0.2f"%investment} Profit $#{"%0.2f"%profit}"
    market_totals.each {|k,v| puts "#{k} spends $#{v[:usd]} #{v[:btc]}btc"}
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
    # bids - offers to buy, price high to low
    # asks - offers to sell, price low to high

    puts "Opportunity calc started. Total markets bid count #{bids.size} ask count #{asks.size}"
    bids = bids.all
    actions = []
    asks.each_with_index do |ask, i|
      print "#{i}. " if i%100==0 && i > 0
      if bids.first.price_with_fee > ask.price_with_fee

        good_bids = bids.select{|b| b.price_with_fee > ask.price_with_fee}
        puts "Profitable bid count #{good_bids.size}"
        if good_bids.last.quantity > 0
          bid_worksheet = consume_offers(good_bids, Balance.make_btc(ask.quantity))
          puts "#{ask.depth_run.market.exchange.name} ask $#{ask.price_with_fee} (orig. $#{ask.price}) x#{"%0.5f"%ask.quantity} $#{ask.cost}"
          usd_in = 0
          bid_worksheet.each do |bw|
            puts "  #{bw[:offer].depth_run.market.exchange.name} bid ##{bw[:offer].id} $#{"%0.2f"%bw[:offer].price_with_fee} ($#{"%0.2f"%bw[:offer].price}) #{"%0.5f"%bw[:offer].quantity}btc qty #{"%0.5f"%bw[:quantity]}btc"
            bw[:offer].quantity -= bw[:quantity]
            usd_in += bw[:quantity] * bw[:offer].price_with_fee
          end
          mini_profit = usd_in - ask.cost
          puts "received $#{"%0.2f"%usd_in}. profit $#{"%0.2f"%mini_profit} "
          if mini_profit > 0
            actions << [ask, bid_worksheet]
          end
        end
      end
    end
    puts
    actions
  end

  def self.consume_offers(offers, money)
    puts "Buying the first #{"%0.5f"%money.amount}#{money.currency} from #{offers.size} offers"
    remaining = money.amount
    actions = []
    offers.each do |offer|
      if remaining > 0.00001 #floatingpoint
        if offer.bidask == 'ask'
          raise "Currency mismatch! #{money.currency} #{offer.depth_run.market.right_currency}" unless money.currency == offer.depth_run.market.right_currency
          quantity_to_buy = [remaining / offer.balance.amount, offer.quantity].min
          spent = offer.balance*quantity_to_buy
        elsif offer.bidask == 'bid'
          raise "Currency mismatch! #{money.currency} #{offer.depth_run.market.left_currency}" unless money.currency == offer.depth_run.market.left_currency
          quantity_to_buy = remaining > offer.quantity ? offer.quantity : remaining
          spent = quantity_to_buy
        end
        remaining -= spent
        actions << {offer: offer, quantity: quantity_to_buy,
                    subtotal: money.amount-remaining}
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

  def self.total_since(time)
    trades = Strategy.where(["created_at > ?", time]).map do |s|
              [s.trades.first.balance_in.amount,
               s.trades.last.calculated_out]
            end
    trades.sum{|t| t.last - t.first}
  end
end
