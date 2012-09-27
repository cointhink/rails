namespace :btc do
  desc 'Record stats about each market'
  task :snapshot => :environment do

    Market.all.each do |market|
      puts "#{market.name} polling"
      market.data_poll
      puts "#{market.name} polled"
    end

    puts "Calculating best pair"
    pairs = Market.pair_spreads
    if pairs.size > 0
      best_pair = pairs.first
      Strategy.create_two_trades(best_pair)
    end
  end

  desc 'Best strategy for current conditions'
  task :strategy => :environment do
    actions = Strategy.satisfied_bids
    actions.each{|action| puts action.inspect}
  end
end