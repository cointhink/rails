class Markets::Bitstamp
  def ticker_poll
    data = JSON.parse(Faraday.get('https://www.bitstamp.net/api/ticker/').body)
    attrs = {:highest_bid_usd => data["bid"],
             :lowest_ask_usd => data["ask"]}
  end

  def depth_poll
    data = JSON.parse(Faraday.get('https://www.bitstamp.net/api/order_book/').body)
    data["asks"].map! do |offer|
      { bidask: "ask",
        in_balance_attributes: {amount:offer.first, currency: 'usd'},
        out_balance_attributes: {amount:offer.last, currency: 'btc'}
      }
    end
    data["bids"].map! do |offer|
      { bidask: "bid",
        in_balance_attributes: {amount:offer.last, currency: 'btc'},
        out_balance_attributes: {amount:offer.first, currency: 'usd'}
      }
    end
    data
  end
end