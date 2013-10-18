class Merchant < Mtmodel

    has_one :provider

    def mode= mode_str
        case mode_str.downcase
        when "live"
            self.paused = false
            self.live   = true
        when "coming_soon"
            self.paused = false
            self.live   = false
        when "paused"
            self.paused = true
        else
            # cron job to fix the broken mode_str
            puts "#{self.name} #{self.id} was sent mode_str #{mode_str} - update mode broken"
        end
    end


end