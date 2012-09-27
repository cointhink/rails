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
    best_pair = pairs.first
    Strategy.create_two_trades(best_pair)

  end

  desc 'Best strategy for current conditions'
  task :strategy => :environment do
    pairs = Market.pair_spreads

    profitable_pairs = Strategy.profitable_pairs_asks
    profitable_pairs.each do |pair|
      ask_momentum = pair[1].sum{|a| a.momentum}
      puts "buy market #{pair[0].name} $#{"%0.3f"%ask_momentum} investment. #{pair[2].name}"
      pair[1].each{|a| puts "ask: $#{a.price} #{a.quantity}btc =$#{a.momentum}"}
    end
  end
end