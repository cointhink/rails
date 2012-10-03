class Markets::Bitfloor
  def ticker_poll
    data = JSON.parse(Faraday.get('https://api.bitfloor.com/book/L1/1').body)
    attrs = {:highest_bid_usd => data["bid"].first,
             :lowest_ask_usd => data["ask"].first}
  end

  def depth_poll
    data = JSON.parse(Faraday.get('https://api.bitfloor.com/book/L2/1').body)
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