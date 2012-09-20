class CreateTickers < ActiveRecord::Migration
  def change
    create_table :tickers do |t|
      t.references :market
      t.decimal :hightest_bid_usd
      t.decimal :lowest_ask_usd

      t.timestamps
    end
    add_index :tickers, :market_id
  end
end
