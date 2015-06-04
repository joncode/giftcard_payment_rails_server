class RemoveRememberTokenFromMtUsers < ActiveRecord::Migration
  def change
    remove_column :mt_users, :remember_token
  end
end
