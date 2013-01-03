class IndexDepthRuns < ActiveRecord::Migration
  def up
    add_index :depth_runs, :exchange_run_id
  end
end
