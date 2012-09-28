class CreateExchanges < ActiveRecord::Migration
  def change
    create_table :exchanges do |t|
      t.string :name
      t.decimal :fee_percentage

      t.timestamps
    end

    add_column :markets, :exchange_id, :integer
    add_column :markets, :left_currency, :string
    add_column :markets, :right_currency, :string
    remove_column :markets, :fee_percentage
    remove_column :markets, :name
  end
end
