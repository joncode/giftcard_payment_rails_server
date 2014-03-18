class CreateFriendships < ActiveRecord::Migration
    def change
        create_table :friendships do |t|
          t.integer :user_id
          t.integer :app_contact_id

          t.timestamps
        end

        add_index :friendships, :user_id
        add_index :friendships, :app_contact_id
        add_index :friendships, [:user_id, :app_contact_id], unique: true
    end
end
