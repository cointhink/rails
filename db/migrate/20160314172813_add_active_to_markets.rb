class AddActiveToMarkets < ActiveRecord::Migration
  def change
    add_column :markets, :active, :boolean
  end
end
