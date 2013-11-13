class RemovePhotosFromProviders < ActiveRecord::Migration

    def up
        remove_column :providers, :photo
        remove_column :providers, :box
        remove_column :providers, :logo
        remove_column :providers, :portrait
    end

    def down
        add_column :providers, :photo, :string
        add_column :providers, :box, :string
        add_column :providers, :logo, :string
        add_column :providers, :portrait, :string
    end
end
