class AddBestPriceToDepthRuns < ActiveRecord::Migration
  def change
    add_column :depth_runs, :best_offer_id, :integer
  end
end
