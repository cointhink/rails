class Markets::Bitstamp
  def initialize(market)
    @market = market
  end

  def ticker_poll
    data = JSON.parse(Faraday.get('https://www.bitstamp.net/api/ticker/').body)
    attrs = {:highest_bid_usd => data["bid"],
             :lowest_ask_usd => data["ask"]}
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