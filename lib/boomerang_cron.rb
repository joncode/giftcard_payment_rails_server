module BoomerangCron

    def self.perform
        puts "\n------------- BOOMERANG CRON -----------------"
        boom_gifts = 0
        failed_booms = 0
        gs         = Gift.boomerangable
        count = gs.count
        puts "\n #{count}  boomerangable gifts\n"
        gs.each do |gift|
            new_gift    = GiftBoomerang.create({"old_gift_id" => gift.id})
            if new_gift.class == GiftBoomerang && new_gift.id.present?
                boom_gifts += 1
            elsif new_gift.class == GiftBoomerang
                puts "#{new_gift.inspect} -- #{gift.id}  -- failed to make gift"
                puts "#{new_gift.errors.messages}\n"
                failed_booms += 1
            else
                puts "#{new_gift.inspect} -- #{gift.id}"
                failed_booms += 1
            end
        end
        puts "------------- #{boom_gifts} - good / #{failed_booms} - bad / #{count} - total  boomeranged gifts -----------------\n"

    end
end

