class Exchanges::Poloniex < Exchanges::Base
  def ticker_poll(from_currency, to_currency)
  end

  def depth_poll(conn, from_currency, to_currency)
    # covers two markets, from/to and to/from
    pair = "#{to_currency.upcase}_#{from_currency.upcase}"
    url = "https://poloniex.com/public?command=returnOrderBook&currencyPair=#{pair}"
    body = conn.get(url).body
    JSON.parse(body)
  end
end
