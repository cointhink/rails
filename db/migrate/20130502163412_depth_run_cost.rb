class DepthRunCost < ActiveRecord::Migration
  def change
    add_column :depth_runs, :cost_id, :integer
  end
end
