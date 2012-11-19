class StageParent < ActiveRecord::Migration
  def change
    add_column :stages, :parent_id, :integer
    add_column :stages, :children_concurrent , :boolean
    add_column :stages, :name , :string
  end
end
