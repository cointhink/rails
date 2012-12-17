class AddBestPriceToDepthRuns < ActiveRecord::Migration
  def up
    add_column :depth_runs, :best_offer_id, :integer
    puts "backfilling best_offer_id"
    DepthRun.where("best_offer_id is null").each do |d|
      if d.market.from_currency == 'usd'
        best_offer = d.offers.order('price desc').last 
      else
        best_offer = d.offers.order('price asc').last 
      end
      if best_offer
        d.update_attribute :best_offer_id, best_offer.id
      end
    end
  end

  def down
    remove_column :depth_runs, :best_offer_id
  end
end
