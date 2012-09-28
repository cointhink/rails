class Markets::Intersango
  def ticker_poll
    data = JSON.parse(Faraday.get('https://intersango.com/api/ticker.php').body)["3"]
    attrs = {:highest_bid_usd => data["buy"],
             :lowest_ask_usd => data["sell"]}
  end

  def depth_poll
    data = JSON.parse(Faraday.get('https://intersango.com/api/depth.php?currency_pair_id=3').body)
    data["asks"].map! do |offer|
      { bidask: "ask",
        in_balance_attributes: {amount:offer.first, currency: 'usd'},
        out_balance_attributes: {amount:offer.last, currency: 'btc'}
      }
    end
    data["bids"].map! do |offer|
      { bidask: "bid",
        in_balance_attributes: {amount:offer.last, currency: 'btc'},
        out_balance_attributes: {amount:offer.first, currency: 'usd'}
      }
    end
    data
  end
end