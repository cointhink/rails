class Markets::Mtgox
  def ticker_poll
    data = JSON.parse(Faraday.get('https://mtgox.com/api/1/BTCUSD/ticker').body)["return"]
    attrs = {:highest_bid_usd => data["buy"]["value"],
             :lowest_ask_usd => data["sell"]["value"]}
  end

  def depth_poll
    data = JSON.parse(Faraday.get('https://mtgox.com/api/1/BTCUSD/depth').body)["return"]
    data["asks"].map! do |a|
      { bidask: "ask",
        currency: "usd",
        listed_at: Time.at(a["stamp"].to_i/1000000),
        price: a["price"],
        quantity: a["amount"]
      }
    end
    data["bids"].map! do |a|
      { bidask: "bid",
        currency: "usd",
        listed_at: Time.at(a["stamp"].to_i/1000000),
        price: a["price"],
        quantity: a["amount"]
      }
    end
    data
  end
end
