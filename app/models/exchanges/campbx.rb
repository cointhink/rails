class Exchanges::Campbx < Exchanges::Base
  def ticker_poll(from_currency, to_currency)
    url = "http://campbx.com/api/xticker.php"
    data = JSON.parse(Faraday.get(url).body)
    attrs = {:highest_bid_usd => data["Best Bid"],
             :lowest_ask_usd => data["Best Ask"]}
  end

  def depth_poll(conn, from_currency, to_currency)
    # covers two markets, from/to and to/from
    url = "http://campbx.com/api/xdepth.php"
    JSON.parse(conn.get(url).body)
  end
end
