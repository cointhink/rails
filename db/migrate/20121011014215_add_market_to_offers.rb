class AddMarketToOffers < ActiveRecord::Migration
  def change
    add_column :offers, :market_id, :integer
  end
end
