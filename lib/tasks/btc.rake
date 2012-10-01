namespace :btc do
  desc 'Record stats about each market'
  task :snapshot => :environment do

    Exchange.all.each do |exchange|
      exchange.markets.each do |market|
        puts "#{exchange.name} #{market.left_currency}/#{market.right_currency} polling"
        stats = market.data_poll
        puts stats.inspect
      end
    end

    puts "Calculating best pair"
    pairs = Strategy.pair_spreads
    if pairs.size > 0
      best_pair = pairs.first
      Strategy.create_two_trades(best_pair)
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
  end
end