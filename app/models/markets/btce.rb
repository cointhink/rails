class Markets::Btce
  def ticker_poll
    data = JSON.parse(Faraday.get('https://btc-e.com/api/2/btc_usd/ticker').body)["ticker"]
    #unbelivable bug - buy/sell is swapped in the api results
    attrs = {:highest_bid_usd => data["sell"],
             :lowest_ask_usd => data["buy"]}
  end

  def depth_poll
    data = JSON.parse(Faraday.get('https://btc-e.com/api/2/btc_usd/depth').body)
    data["asks"].map! do |offer|
      { bidask: "ask",
        in_balance: Balance.make_usd(offer.first),
        out_balance: Balance.make_btc(offer.last)
      }
    end
    data["bids"].map! do |offer|
      { bidask: "bid",
        in_balance: Balance.make_btc(offer.last),
        out_balance: Balance.make_usd(offer.first)
      }
    end
    data
  end
end