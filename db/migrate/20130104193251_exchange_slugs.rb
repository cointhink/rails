class ExchangeSlugs < ActiveRecord::Migration
  def change
    add_column :exchanges, :slug, :string
    add_index :exchanges, :slug, unique: true
    Exchange.find_each(&:save)
  end

end
