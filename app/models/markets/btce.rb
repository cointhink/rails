class Markets::Btce
  def data_poll
    data = JSON.parse(Faraday.get('https://btc-e.com/api/2/btc_usd/ticker').body)["ticker"]
    attrs = {:highest_bid_usd => data["buy"],
             :lowest_ask_usd => data["sell"]}
  end
end