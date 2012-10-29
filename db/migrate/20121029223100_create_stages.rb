class CreateStages < ActiveRecord::Migration
  def change
    create_table :stages do |t|
      t.integer :sequence
      t.integer "strategy_id"
      t.integer "balance_in_id"
      t.integer "balance_out_id"
      t.integer "potential_id"

      t.timestamps
    end
    add_index :stages, :strategy_id
    add_index :stages, :balance_in_id
    add_index :stages, :balance_out_id
    add_index :stages, :potential_id
    remove_column :trades, :strategy_id
    add_column :trades, :stage_id, :integer
  end
end
