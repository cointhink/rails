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
    snapshot.poll(super_http, Exchange.with_markets('doge','btc'))
  end

  desc 'Compute strategy'
  task :strategy, [:markets] => :environment do |task, args|
    snapshot = Snapshot.order('created_at desc').first
    if snapshot
      puts "** Snapshot ##{snapshot.id} #{snapshot.created_at} #{snapshot.exchange_runs.map{|er|er.exchange.name}}"
      puts "** BTC/USD run"
      btc_strategy = Strategy.opportunity('btc', 'usd', snapshot)
      snapshot.strategies << btc_strategy if btc_strategy
      puts "** LTC/BTC run"
      ltc_strategy = Strategy.opportunity('ltc', 'btc', snapshot)
      snapshot.strategies <<  ltc_strategy if ltc_strategy
      puts "** DOGE/BTC run"
      doge_strategy = Strategy.opportunity('doge', 'btc', snapshot)
      snapshot.strategies << doge_strategy if doge_strategy
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
