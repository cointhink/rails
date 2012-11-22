namespace :btc do
  desc 'Record stats about each market'
  task :snapshot => :environment do
    # exchanges with internal markets
    super_http = Faraday.new(request:{timeout:SETTINGS["net"]["timeout"]})

    snapshot = Snapshot.create
    snapshot.poll(super_http, Exchange.actives)
  end

  desc 'Total opportunity'
  task :opportunity, [:markets] => :environment do |task, args|
    snapshot = Snapshot.order('created_at desc').first
    if snapshot
      puts "Snapshot ##{snapshot.id} #{snapshot.created_at}"
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
