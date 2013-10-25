class AddLiveAndPausedToProviders < ActiveRecord::Migration
    def up
        add_column :providers, :live, :boolean, default: false
        add_column :providers, :paused, :boolean, default: true

        set_legacy_data
    end

    def down
        remove_column :providers, :live
        remove_column :providers, :paused
    end

    def set_legacy_data
        ps = Provider.unscoped
        ps.each do |p|
            #puts "Before- #{p.name} - sd_location_id:#{p.sd_location_id} - active:#{p.active}"
            legacy_status(p)
            #puts "After- #{p.name} - live:#{p.live} - active:#{p.active} - pause:#{p.paused}"
        end
        nil
    end

    def legacy_status(provider)
        if provider.active
            if provider.sd_location_id == 1
                stat = "live"
            else
                stat = "coming_soon"
            end
        else
            stat = "paused"
        end
        provider.mode = stat
        provider.save
        puts "---------------------------------------"
        puts "provider #{provider.id} - Now = #{provider.mode} | Old = #{stat} ~ |#{provider.sd_location_id} | #{provider.active}"
    end
end
