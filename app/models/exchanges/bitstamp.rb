class Exchanges::Bitstamp < Exchanges::Base
  def depth_poll(conn, from_currency, to_currency)
    # covers two markets, from/to and to/from
    url = "https://www.bitstamp.net/api/order_book/"
    JSON.parse(conn.get(url).body)
  end
end