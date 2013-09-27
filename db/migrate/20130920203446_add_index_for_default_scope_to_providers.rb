class AddIndexForDefaultScopeToProviders < ActiveRecord::Migration
    def up
        add_index :providers, [:active, :paused, :city]
    end

    def down
        remove_index :providers, [:active, :paused, :city]
    end
end

