class Markets::Intersango
  def initialize(market)
    @market = market
  end

  def ticker_poll
    data = JSON.parse(Faraday.get('https://intersango.com/api/ticker.php').body)["3"]
    attrs = {:highest_bid_usd => data["buy"],
             :lowest_ask_usd => data["sell"]}
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