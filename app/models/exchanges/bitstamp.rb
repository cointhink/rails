class Exchanges::Bitstamp
  def depth_poll(from_currency, to_currency)
    # covers two markets, from/to and to/from
    url = "https://www.bitstamp.net/api/order_book/"
    JSON.parse(Faraday.get(url).body)
  end
end