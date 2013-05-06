class Strategy < ActiveRecord::Base
  belongs_to :balance_in, :class_name => :Balance, :dependent => :destroy
  belongs_to :balance_out, :class_name => :Balance, :dependent => :destroy
  belongs_to :potential, :class_name => :Balance, :dependent => :destroy

  has_one :stage, :dependent => :destroy
  has_many :exchange_balances, :dependent => :destroy

  # total opportunity
  def self.opportunity(left_currency, right_currency, snapshot)
    # find all asks less than bids, fee adjusted
    # assume unlimited buying funds
    depth_runs = snapshot.exchange_runs.map{|er| er.depth_runs}.flatten
    bid_markets = depth_runs.select{|dr| dr.market.bidask(right_currency) == 'bid'}
    ask_markets = depth_runs.select{|dr| dr.market.bidask(right_currency) == 'ask'}

    puts "Ask Markets: #{ask_markets.map{|dr| "#{dr.market.name}"}.join(', ')}"
    puts "Bid Markets: #{bid_markets.map{|dr| "#{dr.market.name}"}.join(', ')}"

    bids = Offer.where(['depth_run_id in (?)', bid_markets]).order("price desc")
    asks = Offer.where(['depth_run_id in (?)', ask_markets]).order("price asc")

    if bids.count > 0 && asks.count > 0
      actions = clearing_offers(bids, asks)
      strategy = Strategy.analyze(actions)
      snapshot.update_attribute :strategy, strategy
      puts "Linked strategy ##{strategy.id} to snapshot ##{snapshot.id} #{snapshot.created_at}"
    else
      puts "#{bids.count} bids. #{asks.count} asks. Nothing actionable."
    end
  end

  def self.analyze(actions)
    strategy = Strategy.create
    puts "Saving #{actions.size} trade groups"
    parent = strategy.create_stage
    stage2 = parent.children.create(sequence: 2, name: "Trades",
                                   children_concurrent: true)
    market_totals = {}
    ActiveRecord::Base.transaction do
      actions.each do |action|
        substage = stage2.children.create
        market = market_totals[action[:buy].market.exchange.name] ||= Hash.new(0)
        market[:usd] += action[:buy].cost(action[:quantity]).amount

        # buy low
        substage.trades.create(balance_in: action[:buy].cost(action[:quantity])*(1+action[:buy].market.fee),
                               offer: action[:buy],
                               expected_fee: action[:buy].market.fee_percentage)

        # sell high
        action[:sells].each do |sell|
          market = market_totals[sell[:offer].market.exchange.name] ||= Hash.new(0)
          market[:btc] += sell[:spent].amount
          substage.trades.create(balance_in: sell[:spent],
                                 offer: sell[:offer],
                                 expected_fee: sell[:offer].market.fee_percentage)

        end
        substage.balance_in = substage.balance_in_calc
        substage.balance_out = substage.balance_usd_out
        substage.potential = substage.balance_out - substage.balance_in
        substage.save
      end
    end
    stage2.balance_in = stage2.children.reduce(Balance.make_usd(0)) do |total, trade|
      total + trade.balance_in
    end
    stage2.balance_out = stage2.children.reduce(Balance.make_usd(0)) do |total, trade|
      total + trade.balance_usd_out
    end
    stage2.potential = stage2.balance_out - stage2.balance_in
    stage2.save
    puts "Stage #{stage2.name} ##{stage2.id} #{stage2.children.count} actions. Investment #{stage2.balance_in} Profit #{stage2.potential} #{"%0.2f"%stage2.profit_percentage}%"

    stage1 = parent.children.create(sequence: 1,
                                   name: "Moves",
                                   children_concurrent: true)
    puts "Finding changers for #{market_totals.keys.size} markets"
    market_totals.each do |k,v|
      exchange = Exchange.find_by_name(k)
      puts "#{k} spends $#{"%0.2f"%v[:usd]} #{"%0.5f"%v[:btc]}btc"
      if v[:usd] > 0
        changer = exchange.best_changer(Exchange.find_by_name('mtgox'), 'usd')
        v[:usd] *= (1+changer.fee)
        puts " -> #{changer.name} $#{"%0.2f"%v[:usd]} #{changer.fee_percentage}% fee"
        stage1.trades.create(balance_in: Balance.make_usd(v[:usd]),
                             offer: changer.offers.first,
                             expected_fee: changer.fee_percentage)
      end
      if v[:btc] > 0
        puts "bitcoin changer fee unimplemented"
      end
      strategy.exchange_balances.create(exchange: exchange,
                                        balances: [Balance.make_usd(v[:usd]),
                                                   Balance.make_btc(v[:btc])])
    end
    stage1.balance_in = stage1.balance_in_calc
    stage1.balance_out = stage1.balance_usd_out
    stage1.potential = stage1.balance_out - stage1.balance_in
    stage1.save
    puts "Stage #{stage1.name} ##{stage1.id} Investment #{stage1.balance_in} Profit #{stage1.potential} #{"%0.2f"%stage1.profit_percentage}%"

    parent.balance_in = stage1.balance_in
    parent.balance_out = stage2.balance_out
    parent.potential = parent.balance_out - parent.balance_in
    parent.save

    # duplicate parent amounts into stage (remove?)
    strategy.balance_in = parent.balance_in
    strategy.balance_out = parent.balance_out
    strategy.potential = strategy.balance_out - strategy.balance_in
    strategy.save

    puts "#{strategy.stage.children.count} stages. Investment #{strategy.balance_in} Profit #{strategy.potential}"
    strategy
  end

  def self.clearing_offers(bids, asks)
    best_bid = bids.first
    best_ask = asks.first
    usd_in_total = Balance.make_usd(0)
    usd_out_total = Balance.make_usd(0)
    profit_total = Balance.make_usd(0)
    actions = []

    puts "Best of #{bids.size} bids: #{best_bid.market.name} #{best_bid.rate('usd')}"
    puts "Best of #{asks.size} asks: #{best_ask.market.name} #{best_ask.rate('usd')}"
    good_bids = bids.where(["price > ?", best_ask.price]).all #in-memory copy
    puts "#{good_bids.size} bids above best ask $#{best_ask.price}"
    good_asks = asks.where(["price < ?", best_bid.price]).all #in-memory copy
    puts "#{good_asks.size} asks below best bid $#{best_bid.price}"
    puts "Checking #{good_asks.size} asks for profitability:"

    good_asks.each do |ask|
      puts "Buying #{ask.market.exchange.name} #{ask.bidask} ##{ask.id} #{ask.rate(best_bid.market.to_currency)} x#{"%0.5f"%ask.quantity} #{ask.market.fee_percentage}% fee"
      left = ask.cost(ask.cost)
      bid_worksheet = consume_offers(good_bids, left, ask.rate*(1+ask.market.fee))
      break if bid_worksheet.empty?
      usd_in = Balance.make_usd(0)
      usd_out = Balance.make_usd(0)
      btc_inout = Balance.make_btc(0)
      bid_worksheet.each do |bw|
        btc_inout += bw[:spent].amount
        uout = bw[:offer].cost(bw[:spent])
        usd_out += uout
        uin = ask.cost(bw[:spent])
        usd_in += uin
        profit = uout - uin
        puts "  #{bw[:offer].market.exchange.name} #{bw[:offer].bidask} ##{bw[:offer].id} $#{bw[:offer].rate('usd')} x#{"%0.5f"%bw[:offer].quantity}btc spent #{bw[:spent]} earned: #{profit}"
      end
      puts "  summary #{usd_in} => #{btc_inout} => #{usd_out}. profit #{usd_out-usd_in}"
      profit_total += usd_out-usd_in
      usd_in_total += usd_in
      usd_out_total += usd_out
      actions << {buy:ask, quantity: btc_inout, sells: bid_worksheet}
    end
    puts "Total usd in: #{usd_in_total} usd out: #{usd_out_total} profit: #{profit_total}"
    actions
  end

  def self.consume_offers(offers, money, price_limit)
    puts "Selling #{money} to #{offers.size} offers better than #{price_limit}"
    remaining = money.dup
    actions = []
    offers.each do |offer|
      if remaining > 0.00001 #floatingpoint
        break if offer.rate(price_limit.currency)*(1-offer.market.fee) < price_limit
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
    bid_after_fee = bid.rate*remaining_factor
    puts "Finding asks above #{bid_after_fee.amount}#{bid_after_fee.currency} (#{bid.rate.amount}#{bid.rate.currency} original, #{fee_percentage}% fee)"
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
    if balance_in && balance_in > 0
      (potential/balance_in).amount*100
    else
      0
    end
  end
end
