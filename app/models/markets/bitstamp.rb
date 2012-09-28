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