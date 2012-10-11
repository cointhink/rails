class Strategy < ActiveRecord::Base
  belongs_to :balance_in, :class_name => :Balance, :dependent => :destroy
  belongs_to :balance_out, :class_name => :Balance, :dependent => :destroy
  belongs_to :potential, :class_name => :Balance, :dependent => :destroy

  # attr_accessible :title, :body
  has_many :trades, :dependent => :destroy

  # total opportunity
  def self.opportunity(left_currency, right_currency)
    # find all asks less than bids, fee adjusted
    # assume unlimited buying funds
    bid_markets = Market.internal.trading(left_currency,right_currency)
    ask_markets = Market.internal.trading(right_currency,left_currency)

    puts "Ask Markets: #{ask_markets.map{|m| "#{m.exchange.name} #{m.from_currency}/#{m.to_currency}"}.join(', ')}"
    puts "Bid Markets: #{bid_markets.map{|m| "#{m.exchange.name} #{m.from_currency}/#{m.to_currency}"}.join(', ')}"

    asks = Offer.trades(right_currency,left_currency).order("price asc")
    bids = Offer.trades(left_currency, right_currency).order("price desc")

    actions = clearing_offers(bids, asks)

    strategy = Strategy.create
    puts "Analyzing #{actions.size} trade groups"
    market_totals = {}
    actions.each do |action|
      ask = action[0]
      btc_spent = action[1]
      buys = action[2]
      market = market_totals[ask.depth_run.market.exchange.name] ||= Hash.new(0)
      market[:usd] += ask.cost(btc_spent)

      # even more crap
      strategy.trades << Trade.new(balance_in: Balance.make_usd(ask.cost(btc_spent)),
                                   balance_out: Balance.make_btc(btc_spent),
                                   market: ask.depth_run.market,
                                   expected_fee: ask.depth_run.market.exchange.fee_percentage,
                                   expected_rate: ask.price)

      buys.each do |bid|
        bm = market_totals[bid[:offer].depth_run.market.exchange.name] ||= Hash.new(0)
        bm[:btc] += bid[:quantity]
        strategy.trades << Trade.new(balance_in: Balance.make_btc(bid[:quantity]),
                                     balance_out: Balance.make_usd(bid[:offer].cost(bid[:quantity])),
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

  def self.clearing_offers(bids, asks)
    best_bid = bids.first
    best_ask = asks.first
    usd_in_total = Balance.make_usd(0)
    usd_out_total = Balance.make_usd(0)
    profit_total = Balance.make_usd(0)
    actions = []

    puts "Best of #{bids.size} bids: #{best_bid.market.name} #{best_bid.balance('usd')}"
    good_bids = bids.where(["price > ?", best_ask.price]).all #in-memory copy
    puts "Bids above #{best_ask.price} is size #{good_bids.size}"
    puts "Best of #{asks.size} asks: #{best_ask.market.name} #{best_ask.balance('usd')}"
    good_asks = asks.where(["price < ?", best_bid.price]).all #in-memory copy
    puts "Asks below #{best_bid.price} is size #{good_asks.size}"
    puts "Checking asks for profitability"

    good_asks.each do |ask|
      puts "#{ask.market.exchange.name} #{ask.bidask} ##{ask.id} $#{ask.balance(best_bid.market.to_currency)} x#{"%0.5f"%ask.quantity}"
      bid_worksheet = consume_offers(good_bids, ask.produces, ask.balance)
      break if bid_worksheet.empty?
      usd_in = Balance.make_usd(0)
      usd_out = Balance.make_usd(0)
      btc_inout = Balance.make_btc(0)
      bid_worksheet.each do |bw|
        btc_inout += bw[:spent].amount
        uout = bw[:offer].produces(bw[:spent].amount)
        usd_out += uout
        uin = ask.cost(bw[:spent].amount)
        usd_in += uin
        profit = uout - uin
        puts "  #{bw[:offer].market.exchange.name} #{bw[:offer].bidask} ##{bw[:offer].id} $#{bw[:offer].balance} ($#{bw[:offer].balance('usd')}) x#{"%0.5f"%bw[:offer].quantity}btc spent #{bw[:spent]} earned: #{profit}"
      end
      puts "  summary #{usd_in} => #{btc_inout} => #{usd_out}. profit #{usd_out-usd_in}"
      profit_total += usd_out-usd_in
      usd_in_total += usd_in
      usd_out_total += usd_out
      actions << []# [ask, usd_in_total, bid_worksheet.last[:offer].balance]
    end
    puts
    puts "usd in: #{usd_in_total} usd out: #{usd_out_total} profit: #{profit_total}"
    actions
  end

  def self.consume_offers(offers, money, price_limit)
    puts "Buying the first #{money} from #{offers.size} offers."
    remaining = money.dup
    actions = []
    offers.each do |offer|
      if remaining > 0.00001 #floatingpoint
        break if offer.balance(price_limit.currency) < price_limit
        spent = offer.spend!(remaining)
        remaining -= spent
        if spent > 0.00001
          actions << {offer: offer, spent: spent }
        end
      end
    end
    actions
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
