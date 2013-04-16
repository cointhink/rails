class TradesStageIndex < ActiveRecord::Migration
  def change
    add_index :trades, :stage_id
  end
end
