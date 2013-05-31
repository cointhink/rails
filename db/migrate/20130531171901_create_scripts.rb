class CreateScripts < ActiveRecord::Migration
  def change
    create_table :scripts do |t|
      t.string :name
      t.string :url
      t.integer :user_id
      t.string :slug

      t.timestamps
    end
    add_index :scripts, :slug, unique: true
  end
end
