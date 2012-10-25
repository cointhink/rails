class Exchanges::Btce < Exchanges::Base
  def depth_poll(conn, from_currency, to_currency)
    # covers two markets, from/to and to/from
    url = 'https://btc-e.com/api/2/btc_usd/depth'
    JSON.parse(conn.get(url).body)
  end
end