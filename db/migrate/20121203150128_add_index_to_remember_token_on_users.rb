class AddIndexToRememberTokenOnUsers < ActiveRecord::Migration
  def up
  	add_index :users, :remember_token
  end

  def down
  	remove_index :users, :remember_token
  end
end
