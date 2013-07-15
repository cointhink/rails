class Exchanges::Btce < Exchanges::Base
  def depth_poll(conn, from_currency, to_currency)
    # public api: /ticker /trades /depth
    # covers two markets, from/to and to/from
    url = "https://btc-e.com/api/2/#{from_currency}_#{to_currency}/depth"
    JSON.parse(conn.get(url).body)
  end
end