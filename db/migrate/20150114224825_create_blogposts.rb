class CreateBlogposts < ActiveRecord::Migration
  def change
    create_table :blogposts do |t|
      t.string :title
      t.string :slug
      t.text :body
      t.boolean :published

      t.timestamps
    end
  end
end
