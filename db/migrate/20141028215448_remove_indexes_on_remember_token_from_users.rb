class RemoveIndexesOnRememberTokenFromUsers < ActiveRecord::Migration
  def up
  	remove_index :users, ["active", "perm_deactive", "remember_token"]
  	remove_index :users, ["remember_token"]
  end

  def down
  	add_index :users, ["active", "perm_deactive", "remember_token"]
  	add_index :users, ["remember_token"]
  end
end
