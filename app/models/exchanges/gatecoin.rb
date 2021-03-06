class Exchanges::Gatecoin < Exchanges::Base
  def ticker_poll(from_currency, to_currency)
  end

  def depth_poll(conn, from_currency, to_currency)
    # covers two markets, from/to and to/from
    pair = "#{from_currency.upcase}#{to_currency.upcase}"
    url = "https://www.gatecoin.com/api/Public/MarketDepth/#{pair}"
    body = conn.get(url).body
    JSON.parse(body)
  end
end
