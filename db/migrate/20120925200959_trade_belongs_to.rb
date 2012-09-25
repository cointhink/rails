class TradeBelongsTo < ActiveRecord::Migration
  def up
    add_column :trades, :balance_in_id, :integer
    add_column :trades, :balance_out_id, :integer
  end

  def down
  end
end
