class CreateBalances < ActiveRecord::Migration
  def change
    create_table :balances do |t|
      t.references :market
      t.string :currency
      t.decimal :amount

      t.timestamps
    end
    add_index :balances, :market_id
  end
end
