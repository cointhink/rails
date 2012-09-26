class CreateDepths < ActiveRecord::Migration
  def change
    create_table :depths do |t|
      t.string :currency
      t.decimal :price
      t.decimal :quantity
      t.timestamp :listed_at
      t.references :market
      t.string :bidask

      t.timestamps
    end
    add_index :depths, :market_id
  end
end
