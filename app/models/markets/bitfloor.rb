class Markets::Bitfloor
  def initialize(market)
    @market = market
  end

  def ticker_poll
    data = JSON.parse(Faraday.get('https://api.bitfloor.com/book/L1/1').body)
    attrs = {:highest_bid_usd => data["bid"].first,
             :lowest_ask_usd => data["ask"].first}
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