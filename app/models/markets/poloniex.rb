class Markets::Poloniex
  def initialize(market)
    @market = market
  end

  def offers(data, bidask, currency)
    data[bidask+"s"].map do |offer|
      { bidask: bidask,
        price: offer[0].to_f,
        quantity: offer[1],
        currency: currency
      }
    end
  end
end
