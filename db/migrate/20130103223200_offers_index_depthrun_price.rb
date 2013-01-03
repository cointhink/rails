class OffersIndexDepthrunPrice < ActiveRecord::Migration
  def up
    remove_index "offers", "price"
    add_index "offers", ["depth_run_id","price"]
  end

  def down
  end
end
