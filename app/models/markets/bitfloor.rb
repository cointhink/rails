class Markets::Bitfloor
  def initialize(market)
    @market = market
  end

  def ticker_poll
    data = JSON.parse(Faraday.get('https://api.bitfloor.com/book/L1/1').body)
    attrs = {:highest_bid_usd => data["bid"].first,
             :lowest_ask_usd => data["ask"].first}
  end

  def offers(data, bidask, currency)
    data[bidask+"s"].map do |offer|
      { bidask: bidask,
        price: offer.first,
        quantity: offer.last,
        currency: currency
      }
    end
  end
end