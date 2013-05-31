class CreateScripts < ActiveRecord::Migration
  def change
    create_table :scripts do |t|

      t.timestamps
    end
  end
end
