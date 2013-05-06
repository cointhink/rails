class Markets::Bitcoin24
  def initialize(market)
    @market = market
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