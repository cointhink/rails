class Markets::Btce
  def data_poll
    data = JSON.parse(Faraday.get('https://btc-e.com/api/2/btc_usd/ticker').body)["ticker"]
    #unbelivable bug - buy/sell is swapped in the api results
    attrs = {:highest_bid_usd => data["sell"],
             :lowest_ask_usd => data["buy"]}
  end
end