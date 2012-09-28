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
    task :bestbid => :environment do
      actions = Strategy.satisfied_bids
      actions.each do |action|
        bid = action.first
        actions = action.last
        puts "bid #{bid.depth_run.market.name} #{bid.out_balance.amount}#{bid.out_balance.currency} x#{bid.in_balance.amount}"
        actions.each do |action|
          ask = action.first
          quantity = action.last
          puts "[ask #{ask.depth_run.market.name} #{ask.in_balance.amount}#{ask.in_balance.currency} <=> #{ask.out_balance.amount}#{ask.out_balance.currency}]  qty #{quantity}"
        end
      end
    end
  end
end