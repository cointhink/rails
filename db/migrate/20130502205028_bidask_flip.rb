class BidaskFlip < ActiveRecord::Migration
  def up
    ExchangeRun.order("created_at desc").limit(6).each do |er|
      puts "er #{er.exchange.name} id #{er.id}"
      if er.depth_runs.count == 2
        a=er.depth_runs[0]
        b=er.depth_runs[1]
        if a.market.bidask('usd') == 'bid'
          bid = a
          ask = b
        else
          bid = b
          ask = a
        end
        puts "ask #{ask.id} offer count #{ask.offers.count} bid #{bid.id} offer count #{bid.offers.count}"
        best_ask = ask.offers.order('price asc').first
        worst_ask = ask.offers.order('price asc').last
        best_bid = bid.offers.order('price desc').first
        worst_bid = bid.offers.order('price desc').last
        puts "best ask price #{best_ask.price} best bid price #{best_bid.price} worst ask #{worst_ask.price} worst bid #{worst_bid.price}"
        puts "ask recorded best offer #{ask.best_offer.price}. bid recorded best offer #{bid.best_offer.price}"
        if best_ask.price < best_bid.price
          puts "!! swapped! ask mkt id #{ask.market.id} bid mkt id #{bid.market.id} #{er.created_at}"
          temp_market = bid.market
          bid.market = ask.market
          bid.best_offer = worst_bid
          bid.save!
          ask.market = temp_market
          ask.best_offer = worst_ask
          ask.save!
          puts "!! post swapped! ask mkt id #{ask.market.id} bid mkt id #{bid.market.id} #{er.created_at}"
          ask.offers.each{|o| o.market = bid.market; o.save!}
          bid.offers.each{|o| o.market = ask.market; o.save!}
        else
          puts "ok! #{ask} #{bid} #{er.created_at}"
        end
      else
       puts "destroying half run"
       er.destroy
      end
    end
  end

  def down
  end
end
