namespace :btc do
  desc 'Record stats about each market'
  task :snapshot => :environment do
    #autoloader hack
    require 'exchanges/base'
    # exchanges with internal markets
    super_http = Faraday.new(request:{timeout:SETTINGS["net"]["timeout"]})

    snapshot = Snapshot.create
    snapshot.poll(super_http, Exchange.with_markets('btc','usd'))
    snapshot.poll(super_http, Exchange.with_markets('ltc','btc'))
  end

  desc 'Compute strategy'
  task :strategy, [:markets] => :environment do |task, args|
    snapshot = Snapshot.order('created_at desc').first
    if snapshot
      puts "Snapshot ##{snapshot.id} #{snapshot.created_at} #{snapshot.exchange_runs.map{|er|er.exchange.name}}"
      opportunity = Strategy.opportunity('btc', 'usd', snapshot)
    else
      puts "No snapshots in system"
    end
  end

  desc 'Backfill Total opportunity'
  task :backfill, [:markets] => :environment do |task, args|
    snapshots = Snapshot.where('strategy_id is null')
    snapshots.each do |snapshot|
      Strategy.opportunity('btc', 'usd', snapshot)
    end
  end

  desc 'Best pair of markets'
  task :bestpair => :environment do
    puts "Calculating best pair"
    pairs = Strategy.pair_spreads
    if pairs.size > 0
      best_pair = pairs.first
      Strategy.create_two_trades(best_pair)
    end
  end
end
