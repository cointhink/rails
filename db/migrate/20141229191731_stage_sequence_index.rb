class StageSequenceIndex < ActiveRecord::Migration
  def change
   add_index :stages, :sequence
  end
end
