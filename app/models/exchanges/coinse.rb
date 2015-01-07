class Exchanges::Coinse < Exchanges::Base
  def depth_poll(conn, from_currency, to_currency)
    # covers two markets, from/to and to/from
    url = "https://www.coins-e.com/api/v2/market/#{from_currency}_#{to_currency}/depth/"
    JSON.parse(conn.get(url).body)['marketdepth']
  end
end
