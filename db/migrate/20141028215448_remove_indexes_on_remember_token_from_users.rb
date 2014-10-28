class RemoveIndexesOnRememberTokenFromUsers < ActiveRecord::Migration
  def change
  	remove_index :users, ["active", "perm_deactive", "remember_token"]
  	remove_index :users, ["remember_token"]
  end
end
