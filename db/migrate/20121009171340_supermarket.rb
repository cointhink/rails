class Supermarket < ActiveRecord::Migration
  def change
    remove_column :exchanges, :fee_percentage
    remove_column :markets, :left_currency
    remove_column :markets, :right_currency

    add_column :markets, :from_exchange_id, :integer
    add_column :markets, :from_currency, :string
    add_column :markets, :to_exchange_id, :integer
    add_column :markets, :to_currency, :string
    add_column :markets, :fee_percentage, :decimal
    add_column :markets, :delay_ms, :integer
  end
end
