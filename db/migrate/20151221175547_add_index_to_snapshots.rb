class AddIndexToSnapshots < ActiveRecord::Migration
  def change
    add_index :snapshots, :created_at
  end
end
