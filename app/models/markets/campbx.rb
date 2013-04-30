class Markets::Campbx
  # keep in mind that cbx does only BTC<->USD
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
        listed_at: Time.now, #cbx doesn't provide this
        price: offer[0],
        quantity: offer[1],
        currency: currency
      }
    end
  end
end
