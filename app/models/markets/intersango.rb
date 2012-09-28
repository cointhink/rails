class Markets::Intersango
  def ticker_poll
    data = JSON.parse(Faraday.get('https://intersango.com/api/ticker.php').body)["3"]
    attrs = {:highest_bid_usd => data["buy"],
             :lowest_ask_usd => data["sell"]}
  end

  def depth_poll
    data = JSON.parse(Faraday.get('https://intersango.com/api/depth.php?currency_pair_id=3').body)
    data["asks"].map! do |offer|
      { bidask: "ask",
        price: offer.first,
        quantity: offer.last
      }
    end
    data["bids"].map! do |offer|
      { bidask: "bid",
        price: offer.first,
        quantity: offer.last
      }
    end
    data
  end
end