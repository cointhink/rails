class Markets::Gatecoin
  def initialize(market)
    @market = market
  end

  def offers(data, bidask, currency)
    data[bidask+"s"].map do |offer|
      { bidask: bidask,
        price: offer['price'],
        quantity: offer['volume'],
        currency: currency
      }
    end
  end
end
