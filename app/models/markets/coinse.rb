class Markets::Coinse
  def initialize(market)
    @market = market
  end

  def offers(data, bidask, currency)
    data[bidask+"s"].map do |offer|
      { bidask: bidask,
        price: offer['r'],
        quantity: offer['cq'],
        currency: currency
      }
    end
  end
end
