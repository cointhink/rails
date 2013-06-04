class ScriptBody < ActiveRecord::Migration
  def change
    add_column :scripts, :body, :string
  end
end
