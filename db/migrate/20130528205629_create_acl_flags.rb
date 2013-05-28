class CreateAclFlags < ActiveRecord::Migration
  def change
    create_table :acl_flags do |t|
      t.string :name

      t.timestamps
    end

    create_table :authorizations do |t|
      t.integer :acl_flag_id
      t.integer :user_id

      t.timestamps
    end
  end
end
