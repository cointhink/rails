class UserSlugs < ActiveRecord::Migration
  def up
    add_column :users, :slug, :string
    User.all.each{|u| pass = u.save; puts "FAIL for #{u.username}" unless pass}
  end

  def down
    remove_column :users, :slug
  end
end
