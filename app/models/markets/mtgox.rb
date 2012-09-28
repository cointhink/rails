class Markets::Mtgox
  def ticker_poll
    data = JSON.parse(Faraday.get('https://mtgox.com/api/1/BTCUSD/ticker').body)["return"]
    attrs = {:highest_bid_usd => data["buy"]["value"],
             :lowest_ask_usd => data["sell"]["value"]}
  end

  def depth_poll
    data = JSON.parse(Faraday.get('https://mtgox.com/api/1/BTCUSD/depth').body)["return"]
    data["asks"].map! do |offer|
      { bidask: "ask",
        currency: "btc",
        listed_at: Time.at(offer["stamp"].to_i/1000000),
        balance_attributes: {amount:offer["price"], currency: 'usd'},
        quantity: offer["amount"]
      }
    end
    data["bids"].map! do |offer|
      { bidask: "bid",
        currency: "btc",
        listed_at: Time.at(offer["stamp"].to_i/1000000),
        balance_attributes: {amount:offer["price"], currency: 'usd'},
        quantity: offer["amount"]
      }
    end
    data
  end
end
