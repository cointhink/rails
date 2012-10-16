class ExchangeDetails < ActiveRecord::Migration
  def change
    add_column :exchanges, :country_code, :string
  end
end
