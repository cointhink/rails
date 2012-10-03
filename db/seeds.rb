Exchange.create(name:'mtgox', fee_percentage: 0.6)
Exchange.create(name:'bitstamp', fee_percentage: 0.5)
Exchange.create(name:'intersango', fee_percentage: 0.65)
Exchange.create(name:'btce', fee_percentage: 0.2)
Exchange.create(name:'bitfloor', fee_percentage:0.4)

Exchange.all.each{|e| e.markets.create(left_currency:'btc', right_currency:'usd')}
