class Exchanges::Mtgox
  def ticker_poll(from_currency, to_currency)
    url = "https://mtgox.com/api/1/#{from_currency.upcase}#{to_currency.upcase}/ticker"
    data = JSON.parse(Faraday.get(url).body)["return"]
    attrs = {:highest_bid_usd => data["buy"]["value"],
             :lowest_ask_usd => data["sell"]["value"]}
  end

  def depth_poll(from_currency, to_currency)
    # covers two markets, from/to and to/from
    url = "https://mtgox.com/api/1/#{from_currency.upcase}#{to_currency.upcase}/depth"
    JSON.parse(Faraday.get(url).body)["return"]
  end
end