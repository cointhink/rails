class Markets::Bitstamp
  def data_poll
    data = JSON.parse(Faraday.get('https://www.bitstamp.net/api/ticker/').body)
    attrs = {:highest_bid_usd => data["bid"],
             :lowest_ask_usd => data["ask"]}
  end
end