class Markets::Coinbase
  def initialize(market)
    @market = market
  end

  def offers(data, bidask, currency)
    data[bidask+"s"].map do |offer|
      { bidask: bidask,
        price: offer[0],
        quantity: offer[1],
        currency: currency
      }
    end
  end
end
