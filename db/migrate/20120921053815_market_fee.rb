class MarketFee < ActiveRecord::Migration
  def change
    add_column :markets, :fee_percentage, :decimal
  end
end
