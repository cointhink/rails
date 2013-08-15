class Exchanges::Cryptsy < Exchanges::Base
  def depth_poll(conn, from_currency, to_currency)
    # public api: /ticker /trades /depth
    # covers two markets, from/to and to/from
    url = "http://pubapi.cryptsy.com/api.php?method=orderdata"
    orderbook = JSON.parse(conn.get(url).body)["return"]
    market = orderbook[from_currency.upcase]
    asks = market["sellorders"].map{|o| [o["price"],o["quantity"]]}
    bids = market["buyorders"].map{|o| [o["price"],o["quantity"]]}
    {"asks" => asks, "bids" => bids}
  end
end