# Exchanges
[ ['mtgox', 0.6], ['bitstamp', 0.5], ['intersango', 0.65],
  ['btce', 0.2], ['bitfloor', 0.4] ].each do |info|
  e = Exchange.create(name:info.first)
  e.markets.create(from_exchange: e, from_currency:'btc', 
                   to_exchange: e, to_currency:'usd', fee_percentage: info.last, delay_ms: 500)
  e.markets.create(from_exchange: e, from_currency:'usd', 
                   to_exchange: e, to_currency:'btc', fee_percentage: info.last, delay_ms: 500)
  e.balances.create({currency:"usd", amount: 0})
  e.balances.create({currency:"btc", amount: 0})
end

# Money Changers
e = Exchange.create(name:'bitinstant')
e.markets.create(from_exchange: Exchange.find_by_name('dwolla'), from_currency:'btc', 
                   to_exchange: Exchange.find_by_name('btce'),   to_currency:'usd', 
                 fee_percentage: 2.0, delay_ms: 1000 * 60 * 60 * 12)

# bitcoin client
e = Exchange.create(name:'bitcoin')
e.balances.create({currency:"btc", amount: 0})
