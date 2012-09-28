namespace :btc do
  desc 'Record stats about each market'
  task :snapshot => :environment do

    Market.all.each do |market|
      puts "#{market.name} polling"
      stats = market.data_poll
      puts stats.inspect
    end

    puts "Calculating best pair"
    pairs = Market.pair_spreads
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
        puts "bid #{bid.depth_run.market.name} #{bid.balance.amount}#{bid.balance.currency} x#{bid.other_balance.amount}"
        actions.each do |action|
          ask = action.first
          quantity = action.last
          puts "ask #{ask.depth_run.market.name} #{ask.balance.amount}#{ask.balance.currency} x#{ask.other_balance.amount} #{quantity}"
        end
      end
    end
  end
end