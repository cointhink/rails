class CreateExchangeRuns < ActiveRecord::Migration
  def change
    remove_column :exchanges, :last_http_duration_ms
    add_column :depth_runs, :exchange_run_id, :integer
    create_table :exchange_runs do |t|
      t.references :exchange
      t.references :snapshot
      t.integer :duration_ms
      t.timestamp :start_at
      t.timestamps
    end
  end
end
