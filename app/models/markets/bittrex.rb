class Markets::Bittrex
  def initialize(market)
    @market = market
  end

  def offers(data, bidask, currency)
    data[bidask+"s"].map do |offer|
      { bidask: bidask,
        price: offer['Rate'],
        quantity: offer['Quantity'],
        currency: currency
      }
    end
  end
end
