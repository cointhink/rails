class CreatePurchases < ActiveRecord::Migration
  def change
    create_table :purchases do |t|
      t.string :disbursement_tx
      t.integer :user_id
      t.integer :balance_id
      t.integer "purchaseable_id"
      t.string  "purchaseable_type"
      t.timestamps
    end
  end
end
