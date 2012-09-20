namespace :btc do
  desc 'Record stats about each market'
  task :snapshot => :environment do

    #Manual for now
    #mtgox
    market = Market.find_or_create_by_name('mtgox')
    data = JSON.parse(Faraday.get('https://mtgox.com/api/1/BTCUSD/ticker').body)["return"]
    attrs = {:highest_bid_usd => data["buy"]["value"],
             :lowest_ask_usd => data["sell"]["value"]}
    market.tickers.create(attrs)
    puts "#{market.name} #{attrs}"

    #bitstamp
    market = Market.find_or_create_by_name('bitstamp')
    data = JSON.parse(Faraday.get('https://www.bitstamp.net/api/ticker/').body)
    attrs = {:highest_bid_usd => data["bid"],
             :lowest_ask_usd => data["ask"]}
    puts "#{market.name} #{attrs}"
  end
end