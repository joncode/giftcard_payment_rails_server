class AddIndexOnActiveToBrands < ActiveRecord::Migration
    def up
        add_index :brands, :active
    end

    def down
        remove_index :brands, :active
    end
end
