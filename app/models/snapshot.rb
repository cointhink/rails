class Snapshot < ActiveRecord::Base
  has_many :exchange_runs, :dependent => :destroy
  belongs_to :strategy

  attr_accessible :strategy

  def exchanges
    exchange_runs.map(&:exchange)
  end

  def poll(http, exchanges)
    edata = []
    exchanges.map do |erun|
      Thread.new do
        begin
          start = Time.now
          data = erun[:exchange].api.depth_poll(http,
                                       erun[:bid_market].from_currency,
                                       erun[:bid_market].to_currency)
          duration = Time.now-start
          edata << {erun:erun, start:start, data:data, duration:duration}
        rescue Faraday::Error::TimeoutError,Errno::EHOSTUNREACH,JSON::ParserError => e
          STDERR.puts "#{exchange.name} #{e}"
        end
      end
    end.each{|t| t.join if t}

    edata.map do |edat|
      exchange_run = exchange_runs.create(
                                     exchange: edat[:erun][:exchange],
                                     duration_ms: (edat[:duration]*1000).to_i,
                                     start_at: edat[:start])
      puts "depth BTCUSD #{edat[:data]["asks"].size + edat[:data]["bids"].size} "+
           "#{edat[:start].strftime("%T")} #{edat[:duration]}s #{exchange_run.duration_ms}ms"
      [edat[:erun][:bid_market], edat[:erun][:ask_market]].each do |market|
        puts "#{market.from_currency}/#{market.to_currency} filtering"
        depth_run = market.depth_filter(edat[:data], edat[:erun][:bid_market].to_currency)
        puts "Created #{depth_run.offers.count} offers"
        depth_run.update_attribute :exchange_run, exchange_run
      end
      exchange_run
    end
  end
end
