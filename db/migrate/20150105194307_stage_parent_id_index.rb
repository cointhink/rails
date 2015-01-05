class StageParentIdIndex < ActiveRecord::Migration
  def change
   add_index :stages, :parent_id
  end
end
