class CreateScriptRuns < ActiveRecord::Migration
  def change
    create_table :script_runs do |t|
      t.integer :script_id
      t.string :json_output

      t.timestamps
    end
  end
end
