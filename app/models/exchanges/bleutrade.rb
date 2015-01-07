class Exchanges::Bleutrade < Exchanges::Base
  def depth_poll(conn, from_currency, to_currency)
    # covers two markets, from/to and to/from
    url = "https://bleutrade.com/api/v2/public/getorderbook?market=#{from_currency}_#{to_currency}&type=all&depth=50"
    odd_names = JSON.parse(conn.get(url).body)['result']
    {"bids" => odd_names['buy'], "asks" => odd_names['sell']}
  end
end
