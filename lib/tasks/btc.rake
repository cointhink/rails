namespace :btc do
  desc 'Record stats about each market'
  task :snapshot => :environment do
    # exchanges with internal markets
    super_http = Faraday.new(request:{timeout:SETTINGS.net.timeout})

    Market.internal.map(&:exchange).uniq.each do |exchange|
      puts "* #{exchange.name} poll"
      bid_market = exchange.markets.internal.trading('btc','usd').first
      if bid_market
        begin
          data = exchange.api.depth_poll(super_http,
                                         bid_market.from_currency,
                                         bid_market.to_currency)
          puts "depth BTCUSD #{data["asks"].size + data["bids"].size}"
          [bid_market, bid_market.pair].each do |market|
            puts "#{market.from_currency}/#{market.to_currency} filtering"
            offers = market.depth_filter(data, bid_market.to_currency)
            puts "Created #{offers.size} offers"
          end
        rescue Faraday::Error::TimeoutError => e
          STDERR.puts "#{exchange.name} #{e}"
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
      if args[:markets]
        markets &= args[:markets].split('-').map{|name| Exchange.find_by_name(name).markets}.flatten
      end
      opportunity = Strategy.opportunity('btc', 'usd')
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