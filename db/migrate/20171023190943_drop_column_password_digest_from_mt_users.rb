class DropColumnPasswordDigestFromMtUsers < ActiveRecord::Migration
  def change
  	remove_column :mt_users, :password_digest, :string
  end
end
