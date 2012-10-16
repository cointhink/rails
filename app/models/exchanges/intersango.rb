class Exchanges::Intersango
  def depth_poll(conn, from_currency, to_currency)
    # covers two markets, from/to and to/from
    # 3 = btc/usd
    url = "https://intersango.com/api/depth.php?currency_pair_id=3"
    JSON.parse(conn.get(url).body)
  end
end