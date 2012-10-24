class Exchanges::Cryptoxchange
  def depth_poll(conn, from_currency, to_currency)
    # covers two markets, from/to and to/from
    # 3 = btc/usd
    url = "http://cryptoxchange.com/api/v0/data/BTCUSD/orderbook.json"
    JSON.parse(conn.get(url).body)
  end
end