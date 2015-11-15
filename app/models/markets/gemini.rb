class Markets::Gemini
  def initialize(market)
    @market = market
  end

  def offers(data, bidask, currency)
    data[bidask+"s"].map do |offer|
      { bidask: bidask,
        price: offer['price'],
        quantity: offer['amount'],
        currency: currency
      }
    end
  end
end
