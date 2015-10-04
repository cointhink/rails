class Exchanges::Kraken < Exchanges::Base
  def ticker_poll(from_currency, to_currency)
  end

  def depth_poll(conn, from_currency, to_currency)
    # covers two markets, from/to and to/from
    from = "XETH" if from_currency == "eth"
    to = "XXBT" if to_currency == "btc"
    pair = "#{from}#{to}"
    url = "https://api.kraken.com/0/public/Depth?pair=#{pair}"
    JSON.parse(conn.get(url).body)['result'][pair]
  end
end
