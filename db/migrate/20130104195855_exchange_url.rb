class ExchangeUrl < ActiveRecord::Migration
  def change
    add_column :exchanges, :logo_url, :string
    add_column :exchanges, :url, :string
  end
end
