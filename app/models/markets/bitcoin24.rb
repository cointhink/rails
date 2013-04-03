class Markets::Bitcoin24
  def initialize(market)
    @market = market
  end

  def offers(data, currency)
    if @market.from_currency == currency
      offer_type = "ask"
    else
      offer_type = "bid"
    end
    data[offer_type+"s"].map do |offer|
      { bidask: offer_type,
        price: offer.first,
        quantity: offer.last,
        currency: currency
      }
    end
  end
end