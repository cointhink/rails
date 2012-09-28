class DepthToOffer < ActiveRecord::Migration
  def change
    rename_table :depths, :offers

    remove_column :offers, :currency
    remove_column :offers, :price
    remove_column :offers, :quantity

    add_column :offers, :in_balance_id, :integer
    add_column :offers, :out_balance_id, :integer
  end
end
