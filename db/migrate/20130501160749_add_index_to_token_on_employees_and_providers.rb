class AddIndexToTokenOnEmployeesAndProviders < ActiveRecord::Migration
    def up
        add_index :employees, :token
        add_index :providers, :token
    end

    def down
        remove_index :employees, :token
        remove_index :providers, :token
    end
end
