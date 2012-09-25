class TradeBalances < ActiveRecord::Migration
  def up
    remove_column :trades, :amount_in
    remove_column :trades, :amount_out
    add_column :balances, :balanceable_id, :integer
    add_column :balances, :balanceable_type, :string
  end
end
