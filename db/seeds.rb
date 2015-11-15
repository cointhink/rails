# Access Control
AclFlag.create({name:"blog"})

# Exchanges
[ [{name:'cointhink', display_name:'CoinThink',country_code: 'us', active: false},       0.5],
  [{name:'mtgox', display_name:'Mt. Gox',country_code: 'jp', active: false},       0.6],
  [{name:'bitstamp', display_name:'Bitstamp', country_code: 'si', active: true},    0.5],
  [{name:'intersango', display_name:'InterSango', country_code: 'gb', active: false}, 0.65],
  [{name:'btce', display_name:'BTC-E', country_code: 'bg', active: true},        0.2],
  [{name:'cryptoxchange', display_name:'CryptoXchange', country_code: 'au', active: false}, 0.4],
  [{name:'bitfloor', display_name:'BitFloor', country_code: 'us', active: false},    0.4],
  [{name:'bitcoin24', display_name:'Bitcoin-24', country_code: 'de', active: false},    0.0],
  [{name:'campbx', display_name:'CampBX', country_code: 'us', active: false},    0.55],
  [{name:'bitfinex', display_name:'Bitfinex', country_code: 'vg', active: true},    0.2],
  [{name:'coinbase', display_name:'Coinbase', country_code: 'us', active: true},    0.0],
  [{name:'cryptsy', display_name:'Cryptsy', country_code: 'us', active: true},    0.3],
  [{name:'gemini', display_name:'Gemini', country_code: 'us', active: true},    0.3],
].each do |info|
  e = Exchange.create(info.first)
  e.markets.create(from_exchange: e, from_currency:'btc',
                   to_exchange: e, to_currency:'usd', fee_percentage: info.last, delay_ms: 500)
  e.markets.create(from_exchange: e, from_currency:'usd',
                   to_exchange: e, to_currency:'btc', fee_percentage: info.last, delay_ms: 500)
  e.balances.create({currency:"usd", amount: 0})
  e.balances.create({currency:"btc", amount: 0})
end

[
  [{name:'coinse', display_name:'Coins-e', country_code: 'ca', active: true},    0.15],
  [{name:'bleutrade', display_name:'Bluetrade', country_code: 'br', active: true},    0.25]
].each do |info|
  e = Exchange.create(info.first)
  e.markets.create(from_exchange: e, from_currency:'doge',
                   to_exchange: e, to_currency:'btc', fee_percentage: info.last, delay_ms: 500)
  e.markets.create(from_exchange: e, from_currency:'btc',
                   to_exchange: e, to_currency:'doge', fee_percentage: info.last, delay_ms: 500)
  e.balances.create({currency:"btc", amount: 0})
  e.balances.create({currency:"doge", amount: 0})
end

[
  [{name:'kraken', display_name:'Kraken', country_code: 'us', active: true},    0.2],
  [{name:'poloniex', display_name:'Poloniex', country_code: 'us', active: true},    0.2]
].each do |info|
  e = Exchange.create(info.first)
  e.markets.create(from_exchange: e, from_currency:'eth',
                   to_exchange: e, to_currency:'btc', fee_percentage: info.last, delay_ms: 500)
  e.markets.create(from_exchange: e, from_currency:'btc',
                   to_exchange: e, to_currency:'eth', fee_percentage: info.last, delay_ms: 500)
  e.balances.create({currency:"btc", amount: 0})
  e.balances.create({currency:"eth", amount: 0})
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
