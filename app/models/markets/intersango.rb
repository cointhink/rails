class Markets::Intersango
  def data_poll
    data = JSON.parse(Faraday.get('https://intersango.com/api/ticker.php').body)["3"]
    attrs = {:highest_bid_usd => data["buy"],
             :lowest_ask_usd => data["sell"]}
  end
end