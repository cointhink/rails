class Strategy < ActiveRecord::Base
  belongs_to :balance_in, :class_name => :Balance, :dependent => :destroy
  belongs_to :balance_out, :class_name => :Balance, :dependent => :destroy
  belongs_to :potential, :class_name => :Balance, :dependent => :destroy

  has_many :stages, :dependent => :destroy
  has_many :exchange_balances, :dependent => :destroy

  # total opportunity
  def self.opportunity(left_currency, right_currency)
    # find all asks less than bids, fee adjusted
    # assume unlimited buying funds
    bid_markets = Market.internal.trading(left_currency,right_currency)
    ask_markets = Market.internal.trading(right_currency,left_currency)

    puts "Ask Markets: #{ask_markets.map{|m| "#{m.exchange.name} #{m.from_currency}/#{m.to_currency}"}.join(', ')}"
    puts "Bid Markets: #{bid_markets.map{|m| "#{m.exchange.name} #{m.from_currency}/#{m.to_currency}"}.join(', ')}"

    asks = Offer.where(['depth_run_id in (?)',
                        ask_markets.select{|m| m.exchange.active}.map{|a| a.depth_runs.last}]).
                 order("price asc")
    bids = Offer.where(['depth_run_id in (?)',
                        bid_markets.select{|m| m.exchange.active}.map{|a| a.depth_runs.last}]).
                 order("price desc")

    if bids.count > 0 && asks.count > 0
      actions = clearing_offers(bids, asks)
      Strategy.analyze(actions)
    else
      puts "#{bids.count} bids. #{asks.count} asks. Nothing actionable."
    end
  end

  def self.analyze(actions)
    strategy = Strategy.create
    puts "Saving #{actions.size} trade groups"
    stage = strategy.stages.create(sequence: 2)
    market_totals = {}
    ActiveRecord::Base.transaction do
      actions.each do |action|
        market = market_totals[action[:buy].market.exchange.name] ||= Hash.new(0)
        market[:usd] += action[:buy].cost(action[:quantity].amount).amount

        # buy low
        stage.trades.create(balance_in: action[:buy].cost(action[:quantity].amount),
                               offer: action[:buy],
                               expected_fee: action[:buy].market.fee_percentage)

        # sell high
        action[:sells].each do |sell|
          market = market_totals[sell[:offer].market.exchange.name] ||= Hash.new(0)
          market[:btc] += sell[:spent].amount
          stage.trades.create(balance_in: sell[:spent],
                                 offer: sell[:offer],
                                 expected_fee: sell[:offer].market.fee_percentage)

        end
      end
    end
    stage.balance_in = stage.balance_in_calc
    stage.balance_out = stage.balance_usd_out
    stage.potential = stage.balance_out - stage.balance_in
    stage.save
    puts "stage ##{stage.sequence} #{stage.trades.count} actions. Investment #{stage.balance_in} Profit #{stage.potential}"

    stage = strategy.stages.create(sequence: 1)
    market_totals.each do |k,v|
      exchange = Exchange.find_by_name(k)
      puts "#{k} spends $#{"%0.2f"%v[:usd]} #{"%0.5f"%v[:btc]}btc"
      if v[:usd] > 0
        changer = exchange.best_changer(Exchange.find_by_name('mtgox'), 'usd')
        if changer
          v[:usd] *= (1+changer.fee)
          puts " -> #{changer.name} #{v[:usd]}"
          stage.trades.create(balance_in: Balance.make_usd(v[:usd]),
                       offer: changer.offers.first,
                       expected_fee: changer.fee_percentage)

        end
      end
      strategy.exchange_balances.create(exchange: exchange,
                                        balances: [Balance.make_usd(v[:usd]),
                                                   Balance.make_btc(v[:btc])])
    end
    stage.balance_in = stage.balance_in_calc
    stage.balance_out = stage.balance_usd_out
    stage.potential = stage.balance_out - stage.balance_in
    stage.save

    strategy.balance_in = strategy.stages.where(sequence:1).first.balance_in_calc
    strategy.balance_out = strategy.stages.where(sequence:1).last.balance_usd_out
    strategy.potential = strategy.balance_out - strategy.balance_in
    strategy.save
    puts "#{strategy.stages.count} stages. Investment #{strategy.balance_in} Profit #{strategy.potential}"

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
      left = ask.produces(ask.balance)*(1-ask.market.fee)
      bid_worksheet = consume_offers(good_bids, left, ask.balance*(1+ask.market.fee))
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
      actions << {buy:ask, quantity: btc_inout, sells: bid_worksheet}
    end
    puts "usd in: #{usd_in_total} usd out: #{usd_out_total} profit: #{profit_total}"
    actions
  end

  def self.consume_offers(offers, money, price_limit)
    puts "Buying the first #{money} over #{price_limit} from #{offers.size} offers."
    remaining = money.dup
    actions = []
    offers.each do |offer|
      if remaining > 0.00001 #floatingpoint
        break if offer.balance(price_limit.currency)*(1-offer.market.fee) < price_limit
        spent = offer.spend!(remaining)
        remaining -= spent
        if spent > 0.00001
          actions << {offer: offer, spent: spent}
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

  def balance_in_calc
    stages.order('sequence').first.balance_in
  end

  def balance_usd_out
    stages.order('sequence').last.balance_usd_out
  end

  def profit_percentage
    (potential/balance_in).amount*100
  end
end
