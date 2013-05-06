class NoteCategory < ActiveRecord::Migration
  def change
    add_column :notes, :category, :string
  end
end
