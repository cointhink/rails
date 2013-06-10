class ScriptDockerStatus < ActiveRecord::Migration
  def change
    add_column :scripts, :docker_status, :string
  end
end
