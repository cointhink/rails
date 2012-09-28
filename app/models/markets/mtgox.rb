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
        listed_at: Time.at(offer["stamp"].to_i/1000000),
        in_balance: Balance.make_usd(offer["price"]),
        out_balance: Balance.make_btc(offer["amount"])
      }
    end
    data["bids"].map! do |offer|
      { bidask: "bid",
        listed_at: Time.at(offer["stamp"].to_i/1000000),
        in_balance: Balance.make_btc(offer["price"]),
        out_balance: Balance.make_usd(offer["amount"])
      }
    end
    data
  end
end
