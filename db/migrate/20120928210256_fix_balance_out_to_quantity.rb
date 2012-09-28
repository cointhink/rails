class FixBalanceOutToQuantity < ActiveRecord::Migration
  def change
    remove_column :offers, :in_balance_id
    remove_column :offers, :out_balance_id
    add_column :offers, :price, :decimal
    add_column :offers, :quantity, :decimal
    add_column :offers, :currency, :string
  end
end
