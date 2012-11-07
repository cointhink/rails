class Snapshot < ActiveRecord::Base
  # attr_accessible :title, :body
  has_many :exchange_runs, :dependent => :destroy

  def poll(http, exchanges)
    exchanges.map do |exchange|
      bid_market = exchange.markets.internal.trading('btc','usd').first
      if bid_market
        exchange_run = exchange_runs.create(exchange: exchange)
        puts "* #{exchange.name} poll"
        Thread.new do
          begin
            start = Time.now
            data = exchange.api.depth_poll(http,
                                           bid_market.from_currency,
                                           bid_market.to_currency)
            duration = Time.now-start
            exchange_run.update_attributes(duration_ms: (duration*1000).to_i,
                                           start_at: start)
            puts "depth BTCUSD #{data["asks"].size + data["bids"].size} #{start.strftime("%T")} #{duration}s"
            [bid_market, bid_market.pair].each do |market|
              puts "#{market.from_currency}/#{market.to_currency} filtering"
              depth_run = market.depth_filter(data, bid_market.to_currency)
              puts "Created #{depth_run.offers.count} offers"
              exchange_run.update_attribute :depth_run, depth_run
            end
          rescue Faraday::Error::TimeoutError,Errno::EHOSTUNREACH,JSON::ParserError => e
            STDERR.puts "#{exchange.name} #{e}"
          end
        end
      end
    end.select{|t| t}.each{|t| t.join}
  end
end
