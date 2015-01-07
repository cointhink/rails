class Exchanges::Bitfinex < Exchanges::Base
  def depth_poll(conn, from_currency, to_currency)
    # covers two markets, from/to and to/from
    url = "https://api.bitfinex.com/v1/book/#{from_currency}#{to_currency}"
    JSON.parse(conn.get(url).body)
  end
end
