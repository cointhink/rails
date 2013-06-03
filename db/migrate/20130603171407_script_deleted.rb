class ScriptDeleted < ActiveRecord::Migration
  def change
    add_column :scripts, :deleted, :boolean
    Script.all.each{|s| s.update_attribute :deleted, false}
  end
end
