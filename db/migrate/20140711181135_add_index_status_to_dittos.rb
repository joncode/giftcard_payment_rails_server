class AddIndexStatusToDittos < ActiveRecord::Migration
    def up
        add_index     :dittos, :status
    end

    def down
        remove_index  :dittos, :status
    end
end
