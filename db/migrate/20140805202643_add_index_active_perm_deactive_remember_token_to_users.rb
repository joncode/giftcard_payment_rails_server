class AddIndexActivePermDeactiveRememberTokenToUsers < ActiveRecord::Migration
  def change
  	add_index :users, [:active,:perm_deactive, :remember_token]
  end
end
