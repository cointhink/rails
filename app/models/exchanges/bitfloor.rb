class Exchanges::Bitfloor
  def depth_poll(conn, from_currency, to_currency)
    # covers two markets, from/to and to/from
    url = 'https://api.bitfloor.com/book/L2/1'
    JSON.parse(conn.get(url).body)
  end
end