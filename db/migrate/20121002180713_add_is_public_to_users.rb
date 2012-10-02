class AddIsPublicToUsers < ActiveRecord::Migration
  def change
    add_column :users, :is_public, :boolean
  end
end
