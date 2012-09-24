class Markets::Mtgox
  def data_poll
    data = JSON.parse(Faraday.get('https://mtgox.com/api/1/BTCUSD/ticker').body)["return"]
    attrs = {:highest_bid_usd => data["buy"]["value"],
             :lowest_ask_usd => data["sell"]["value"]}
  end
end
