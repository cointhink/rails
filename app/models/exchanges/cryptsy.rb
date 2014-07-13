class Exchanges::Cryptsy < Exchanges::Base
  def depth_poll(conn, from_currency, to_currency)
    # public api: /ticker /trades /depth
    # covers two markets, from/to and to/from
    if from_currency == "usd" && to_currency == "btc"
        market_id = "2"
    end
    if from_currency == "ltc" && to_currency == "btc"
        market_id = "3"
    end
    if from_currency == "doge" && to_currency == "btc"
        market_id = "132"
    end
    url = "http://pubapi.cryptsy.com/api.php?method=singleorderdata&marketid=#{market_id}"
    orderbook = JSON.parse(conn.get(url).body)["return"]
    market = orderbook[from_currency.upcase]
    asks = market["sellorders"].map{|o| [o["price"],o["quantity"]]}
    bids = market["buyorders"].map{|o| [o["price"],o["quantity"]]}
    {"asks" => asks, "bids" => bids}
  end
end