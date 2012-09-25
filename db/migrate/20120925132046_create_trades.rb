class CreateTrades < ActiveRecord::Migration
  def change
    create_table :trades do |t|
      t.references :market
      t.decimal :amount_in
      t.decimal :amount_out
      t.decimal :expected_fee
      t.decimal :fee
      t.decimal :expected_rate
      t.decimal :rate
      t.boolean :executed
      t.string :order_id

      t.timestamps
    end
    add_index :trades, :market_id
  end
end
