class RenamesAdminUsersSocial < ActiveRecord::Migration
  def self.up
  	rename_column :admin_users_socials, :admin_user_id, :at_user_id
  	rename_table :admin_users_socials, :at_users_socials
  end
  def self.down
  	rename_column :at_users_socials, :at_user_id, :admin_user_id
  	rename_table :at_users_socials, :admin_users_socials
  end
end
