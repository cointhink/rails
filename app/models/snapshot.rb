class Snapshot < ActiveRecord::Base
  has_many :exchange_runs, :dependent => :destroy
  belongs_to :strategy

  attr_accessible :strategy

  def self.latest
    order('created_at desc').first
  end

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
          if data
            edata << {erun:erun, start:start, data:data, duration:duration}
          else
            puts "!! #{erun[:exchange].name} returned empty data"
          end
        rescue Faraday::Error::TimeoutError,Errno::EHOSTUNREACH,JSON::ParserError,
               Errno::ECONNREFUSED => e
          STDERR.puts "!! #{erun[:exchange].name} #{e}"
        end
      end
    end.each{|t| t.join if t}

    edata.map do |edat|
      exchange_run = exchange_runs.create(
                                     exchange: edat[:erun][:exchange],
                                     duration_ms: (edat[:duration]*1000).to_i,
                                     start_at: edat[:start])
      puts "** #{edat[:erun][:exchange].name} "+
           "#{edat[:data]["asks"].size} asks #{edat[:data]["bids"].size} bids "+
           "#{edat[:start].strftime("%T")} #{"%0.3f"%edat[:duration]}s"
      [edat[:erun][:bid_market], edat[:erun][:ask_market]].each do |market|
        depth_run = market.depth_filter(edat[:data], edat[:erun][:bid_market].to_currency)
        depth_run.update_attribute :exchange_run, exchange_run
      end
      exchange_run
    end
  end
end
