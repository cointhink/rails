class Exchanges::Mtgox
  def depth_poll(from_currency, to_currency)
    # covers two markets, from/to and to/from
    url = "https://mtgox.com/api/1/#{from_currency.upcase}#{to_currency.upcase}/depth"
    JSON.parse(Faraday.get(url).body)["return"]
  end
end