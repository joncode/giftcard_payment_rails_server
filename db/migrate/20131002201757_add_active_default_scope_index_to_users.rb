class AddActiveDefaultScopeIndexToUsers < ActiveRecord::Migration
    def up
        add_index :users, :active
    end

    def down
        remove_index :users, :active
    end
end
