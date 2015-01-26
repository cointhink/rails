class Exchanges::Coinbase < Exchanges::Base
  def depth_poll(conn, from_currency, to_currency)
    # covers two markets, from/to and to/from
    url = "https://api.exchange.coinbase.com/products/#{from_currency}-#{to_currency}/book"
    JSON.parse(conn.get(url).body)
  end
end
