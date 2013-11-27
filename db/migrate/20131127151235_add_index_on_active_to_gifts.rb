class AddIndexOnActiveToGifts < ActiveRecord::Migration
    def up
        add_index :gifts, :active
    end

    def down
        remove_index :gifts, :active
    end
end
