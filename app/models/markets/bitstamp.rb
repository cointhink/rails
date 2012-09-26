class Markets::Bitstamp
  def ticker_poll
    data = JSON.parse(Faraday.get('https://www.bitstamp.net/api/ticker/').body)
    attrs = {:highest_bid_usd => data["bid"],
             :lowest_ask_usd => data["ask"]}
  end

  def depth_poll
    data = JSON.parse(Faraday.get('https://www.bitstamp.net/api/order_book/').body)
    data["asks"].map! do |a|
      { bidask: "ask",
        currency: "usd",
        price: a.first,
        quantity: a.last
      }
    end
    data["bids"].map! do |a|
      { bidask: "bid",
        currency: "usd",
        price: a.first,
        quantity: a.last
      }
    end
    data
  end
end