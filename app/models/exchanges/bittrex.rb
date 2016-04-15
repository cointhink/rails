class Exchanges::Bittrex < Exchanges::Base
  def depth_poll(conn, from_currency, to_currency)
    # covers two markets, from/to and to/from
    url = "https://bittrex.com/api/v1.1/public/getorderbook?market=#{to_currency.upcase}-#{from_currency.upcase}&type=both&depth=50"
    data = JSON.parse(conn.get(url).body)
    {"bids" => data['result']['buy'], "asks" => data['result']['sell']}
  end
end