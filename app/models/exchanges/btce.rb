class Exchanges::Btce
  def depth_poll(from_currency, to_currency)
    # covers two markets, from/to and to/from
    url = 'https://btc-e.com/api/2/btc_usd/depth'
    JSON.parse(Faraday.get(url).body)
  end
end