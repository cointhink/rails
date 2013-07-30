class ScriptEnabledUntil < ActiveRecord::Migration
  def change
    add_column :scripts, :enabled_until, :datetime
  end
end
