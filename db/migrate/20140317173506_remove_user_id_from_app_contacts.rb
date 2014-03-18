class RemoveUserIdFromAppContacts < ActiveRecord::Migration
  def up
    remove_column :app_contacts, :user_id
  end

  def down
      add_column :app_contacts, :user_id, :integer
  end
end
