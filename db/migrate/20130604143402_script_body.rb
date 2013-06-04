class ScriptBody < ActiveRecord::Migration
  def change
    add_column :scripts, :body, :text
  end
end
