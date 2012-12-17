class MissingIndexes1 < ActiveRecord::Migration
  def change
    add_index :exchange_runs, :exchange_id
    add_index :exchange_runs, :snapshot_id
    add_index :offers, :price, :order => {:price => :desc}
    add_index :snapshots, :strategy_id
  end
end
