class ActiveExchange < ActiveRecord::Migration
  def up
    add_column :exchanges, :active, :boolean
    Exchange.all.each{|e| e.update_attribute :active, true}
  end
end
