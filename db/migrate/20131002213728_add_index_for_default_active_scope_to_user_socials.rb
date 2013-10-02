class AddIndexForDefaultActiveScopeToUserSocials < ActiveRecord::Migration
    def up
        add_index :user_socials,  :active
    end

    def down
        remove_index :user_socials, :active
    end
end
