class TradesHaveOffer < ActiveRecord::Migration
  def change
    add_column :trades, :offer_id, :integer
    add_index :trades, :offer_id
    remove_column :trades, :market_id
    remove_column :trades, :expected_rate
  end
end
