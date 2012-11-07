class CreateSnapshots < ActiveRecord::Migration
  def change
    create_table :snapshots do |t|
      t.references :strategy
      t.timestamps
    end
  end
end
