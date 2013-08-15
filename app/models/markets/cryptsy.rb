class Markets::Cryptsy
  def initialize(market)
    @market = market
  end

  def ticker_poll
    # finish
    data = JSON.parse(Faraday.get('http://pubapi.cryptsy.com/api.php?method=marketdata').body)["return"]
    attrs = {:highest_bid_usd => data["markets"]["sell"],
             :lowest_ask_usd => data["markets"]["buy"]}
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