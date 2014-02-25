class AddUserToOauth < ActiveRecord::Migration
  def change
    add_column :oauths, :user_id, :integer
  end
end
