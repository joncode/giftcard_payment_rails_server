class RemovePhotosFromProviders < ActiveRecord::Migration

    def up
            # move photo_url to :image

        ps = Provider.unscoped
        good = 0
        bad  = 0
        total = ps.count
        ps.each do |provider|
            if provider.image != provider.get_photo_old
                provider.image = provider.get_photo_old
                if provider.save
                    good += 1
                else
                    bad += 1
                    puts "Provider FAIL #{provider.id} #{provider.errors.full_messages}"
                end
            else
                good += 1
            end
        end
        puts "Good #{good}"
        puts "Bad #{bad}"
        tot = good + bad
        puts "Total #{total}"
        puts "compare #{tot}"

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
