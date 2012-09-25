class BalanceNoMarket < ActiveRecord::Migration
  def up
    remove_column :balances, :market_id
  end
end
