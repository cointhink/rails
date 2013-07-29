namespace :cointainer do
  desc 'Sync rails users to cointainer users'
  task :sync => :environment do
    puts "Rails user count #{User.count}"
    User.all.each do |user|
      puts user.setup_coin_accounts
    end
  end

end