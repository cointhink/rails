class CreateDepthRuns < ActiveRecord::Migration
  def change
    create_table :depth_runs do |t|
      t.references :market

      t.timestamps
    end

    remove_column :depths, :market_id
    add_column :depths, :depth_run_id, :integer
  end
end
