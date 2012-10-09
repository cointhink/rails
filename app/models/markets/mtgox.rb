class Markets::Mtgox
  def initialize(market)
    @market = market
  end

  def offers(data)
    if @market.from_currency == 'btc'
      offer_type = "ask"
    else
      offer_type = "bid"
    end
    data[offer_type+"s"].map do |offer|
      { bidask: offer_type,
        listed_at: Time.at(offer["stamp"].to_i/1000000),
        price: offer["price"],
        quantity: offer["amount"]
      }
    end
  end
end
