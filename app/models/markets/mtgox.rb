class Markets::Mtgox
  def initialize(market)
    @market = market
  end

  def offers(data, bidask, currency)
    data[bidask+"s"].map do |offer|
      { bidask: bidask,
        listed_at: Time.at(offer["stamp"].to_i/1000000),
        price: offer["price"],
        quantity: offer["amount"],
        currency: currency
      }
    end
  end
end
