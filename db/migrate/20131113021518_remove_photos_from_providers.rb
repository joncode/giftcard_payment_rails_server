class RemovePhotosFromProviders < ActiveRecord::Migration

    def up
            # move photo_url to :image
        ps = Provider.unscoped
        ps.each do |provider|
            provider.image = provider.get_photo
            provider.save
        end
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
