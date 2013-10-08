class AddPermDeactiveToUsers < ActiveRecord::Migration
    def up
        add_column :users, :perm_deactive, :boolean, default: false
        add_index :users, [:active, :perm_deactive]
    end

    def down
        remove_index :users,[:active, :perm_deactive]
        remove_column :users, :perm_deactive
    end
end
