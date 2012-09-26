namespace :btc do
  desc 'Record stats about each market'
  task :snapshot => :environment do

    ['mtgox', 'bitstamp', 'intersango', 'btce'].each do |market_name|
      market = Market.find_or_create_by_name(market_name)
      puts "#{market.name} polling"
      market.data_poll
      puts "#{market.name} polled"
    end

    puts "Calculating best pair"
    pairs = Market.pair_spreads
    best_pair = pairs.first
    Strategy.create_two_trades(best_pair)

  end

  desc 'Best strategy for current conditions'
  task :strategy => :environment do
    pairs = Market.pair_spreads

    price_pairs = Strategy.price_pairs(pairs)
    puts price_pairs.inspect
  end
end