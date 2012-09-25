class CreateStrategies < ActiveRecord::Migration
  def change
    create_table :strategies do |t|

      t.timestamps
    end
  end
end
