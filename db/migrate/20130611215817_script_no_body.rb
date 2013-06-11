class ScriptNoBody < ActiveRecord::Migration
  def change
    remove_column :scripts, :body
  end
end
