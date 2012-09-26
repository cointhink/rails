class Markets::Btce
  def ticker_poll
    data = JSON.parse(Faraday.get('https://btc-e.com/api/2/btc_usd/ticker').body)["ticker"]
    #unbelivable bug - buy/sell is swapped in the api results
    attrs = {:highest_bid_usd => data["sell"],
             :lowest_ask_usd => data["buy"]}
  end

  def depth_poll
    data = JSON.parse(Faraday.get('https://btc-e.com/api/2/btc_usd/depth').body)
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