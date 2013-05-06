class Exchanges::Bitcoin24 < Exchanges::Base
  def ticker_poll(from_currency, to_currency)
    url = "https://bitcoin-24.com/api/#{to_currency.upcase}/ticker.json"
    data = JSON.parse(Faraday.get(url).body)
    attrs = {:highest_bid_usd => data["ask"],
             :lowest_ask_usd => data["bid"]}
  end

  def depth_poll(conn, from_currency, to_currency)
    # covers two markets, from/to and to/from
    url = "https://bitcoin-24.com/api/#{to_currency.upcase}/orderbook.json"
    JSON.parse(conn.get(url).body)
  end
end