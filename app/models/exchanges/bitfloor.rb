class Exchanges::Bitfloor
  def depth_poll(from_currency, to_currency)
    # covers two markets, from/to and to/from
    url = 'https://api.bitfloor.com/book/L2/1'
    JSON.parse(Faraday.get(url).body)
  end
end