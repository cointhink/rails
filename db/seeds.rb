# Exchanges
[ [{name:'mtgox', country_code: 'jp', active: true},       0.6],
  [{name:'bitstamp', country_code: 'si', active: true},    0.5],
  [{name:'intersango', country_code: 'gb', active: false}, 0.65],
  [{name:'btce', country_code: 'ru', active: true},        0.2],
  [{name:'cryptoxchange', country_code: 'au', active: false}, 0.4],
  [{name:'bitfloor', country_code: 'us', active: true},    0.4]
].each do |info|
  e = Exchange.create(info.first)
  e.markets.create(from_exchange: e, from_currency:'btc',
                   to_exchange: e, to_currency:'usd', fee_percentage: info.last, delay_ms: 500)
  e.markets.create(from_exchange: e, from_currency:'usd',
                   to_exchange: e, to_currency:'btc', fee_percentage: info.last, delay_ms: 500)
  e.balances.create({currency:"usd", amount: 0})
  e.balances.create({currency:"btc", amount: 0})
end

# bitcoin client
e = Exchange.create(name:'bitcoin')
e.balances.create({currency:"btc", amount: 0})

# web-banks
e = Exchange.create(name:'dwolla')
e.balances.create({currency:"usd", amount: 0})

# Money Changers
e = Exchange.create(name:'bitinstant')
m1=e.markets.create(from_exchange: Exchange.find_by_name('dwolla'), from_currency:'usd',
                   to_exchange: Exchange.find_by_name('btce'),   to_currency:'usd',
                   fee_percentage: 2.0, delay_ms: 1000 * 60 * 60 * 12)
m2=e.markets.create(from_exchange: Exchange.find_by_name('mtgox'), from_currency:'usd',
                   to_exchange: Exchange.find_by_name('btce'),   to_currency:'usd',
                   fee_percentage: 1.49, delay_ms: 1000 * 20)
m3=e.markets.create(from_exchange: Exchange.find_by_name('mtgox'), from_currency:'usd',
                   to_exchange: Exchange.find_by_name('bitstamp'),   to_currency:'usd',
                   fee_percentage: 1.29, delay_ms: 1000 * 20)
[m1,m2,m3].each do |m|
  d=m.depth_runs.create
  d.offers.create(bidask: 'ask', price: 1, market: m,
                  quantity: 1000000, currency: 'usd')
end

# Exchange's in-house transfer services
e=Exchange.find_by_name('mtgox')
m=e.markets.create(from_exchange: e, from_currency: 'usd',
                 to_exchange: Exchange.find_by_name('dwolla'), to_currency: 'usd',
                 fee_percentage: 0, delay_ms: 1000 * 60 * 60 * 24 * 8)
d=m.depth_runs.create
d.offers.create(bidask: 'ask', price: 1, market: m,
                quantity: 1000000, currency: 'usd')
