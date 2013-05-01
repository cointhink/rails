class AddExchangesDisplayName < ActiveRecord::Migration
  def change
    add_column :exchanges, :display_name, :string
  end
end
