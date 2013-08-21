class SnapshotStrategyTwist < ActiveRecord::Migration
  def change
    add_column :strategies, :snapshot_id, :integer
    puts "re-connecting strategies"
    Snapshot.all.each do |snapshot|
      snapshot.strategy.update_attribute :snapshot_id, snapshot.id
    end
    remove_column :snapshots, :strategy_id
  end
end
