class StrategyCurrencies < ActiveRecord::Migration
  def change
    add_column :strategies, :asset_currency, :string
    add_column :strategies, :payment_currency, :string
  end
end
