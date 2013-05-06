class Exchanges::Mtgox < Exchanges::Base
  def ticker_poll(from_currency, to_currency)
    url = "https://data.mtgox.com/api/2/#{from_currency.upcase}#{to_currency.upcase}/money/ticker"
    data = JSON.parse(Faraday.get(url).body)["data"]
    attrs = {:highest_bid_usd => data["buy"]["value"],
             :lowest_ask_usd => data["sell"]["value"]}
  end

  def depth_poll(conn, from_currency, to_currency)
    # covers two markets, from/to and to/from
    url = "https://data.mtgox.com/api/2/#{from_currency.upcase}#{to_currency.upcase}/money/depth/full"
    JSON.parse(conn.get(url).body)["data"]
  end
end