namespace :btc do
  desc 'Record stats about each market'
  task :snapshot => :environment do

    ['mtgox', 'bitstamp', 'intersango', 'btce'].each do |market_name|
      market = Market.find_or_create_by_name(market_name)
      record = market.data_poll
      puts "#{market.name} #{record.inspect}"
    end

  end
end