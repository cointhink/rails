class ScriptDocker < ActiveRecord::Migration
  def change
    rename_column :scripts, :url, :body_url
    add_column :scripts, :docker_host, :string
    add_column :scripts, :docker_container_id, :string
  end
end
