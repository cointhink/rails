class ForeignKeyIndexes < ActiveRecord::Migration
  def change
    add_index :balances, :balanceable_id
    add_index :balances, :balanceable_type
    add_index :depth_runs, :market_id
    add_index :exchange_balances, :strategy_id
    add_index :exchange_balances, :exchange_id
    add_index :markets, :exchange_id
    add_index :markets, :from_exchange_id
    add_index :markets, :to_exchange_id
    add_index :offers, :depth_run_id
    add_index :offers, :market_id
    add_index :strategies, :balance_in_id
    add_index :strategies, :balance_out_id
    add_index :strategies, :potential_id
    add_index :trades, :balance_in_id
    add_index :trades, :balance_out_id
  end
end
