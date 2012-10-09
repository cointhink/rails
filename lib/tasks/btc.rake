namespace :btc do
  desc 'Record stats about each market'
  task :snapshot => :environment do
    Exchange.all.each do |exchange|
      puts "#{exchange.name}"
      # hackish here
      markets = exchange.markets.internal.trading('btc','usd')
      if markets.size > 0
        puts "depth BTCUSD"
        data = exchange.api.depth_poll('btc','usd')
        [markets, exchange.markets.internal.trading('usd','btc')].flatten.each do |market|
          puts "#{market.from_currency}/#{market.to_currency} filtering"
          offers = market.depth_filter(data)
          puts "Created #{offers.size} offers"
        end
      end
    end
  end

  namespace :strategy do
    desc 'Operate on the best bid'
    task :bestbid, [:amount] => :environment do |task, args|
      actions = Strategy.best_bid(Balance.make_usd(args[:amount]||100))
      actions.each do |action|
        bid = action.first
        actions = action.last
        puts "bid #{bid.depth_run.market.exchange.name} #{bid.balance.amount}#{bid.balance.currency} x#{bid.quantity}"
        actions.each do |action|
          puts "ask #{action[:ask].depth_run.market.exchange.name} #{action[:ask].balance.amount}#{action[:ask].balance.currency} x#{action[:ask].quantity} qty #{"%0.5f"%action[:quantity]}. subtotal #{"%0.2f"%action[:subtotal]}"
        end
        action_coins = actions.sum{|a| a[:quantity]}
        bid_sale = action_coins*bid.price
        puts "Coin balance after purchase run: #{"%0.5f"%action_coins}, selling at bid = #{"%0.2f"%bid_sale}"
      end
    end

    desc 'Total opportunity'
    task :opportunity, [:markets] => :environment do |task, args|
      ask_markets = Market.trading('btc','usd')
      bid_markets = Market.trading('usd','btc')
      if args[:markets]
        markets &= args[:markets].split('-').map{|name| Exchange.find_by_name(name).markets}.flatten
      end
      opportunity = Strategy.opportunity(ask_markets, bid_markets)
      #puts opportunity.inspect
    end

    desc 'Best pair of markets'
    task :bestpair => :environment do
      puts "Calculating best pair"
      pairs = Strategy.pair_spreads
      if pairs.size > 0
        best_pair = pairs.first
        Strategy.create_two_trades(best_pair)
      end
    end
  end
end