module BoomerangCron

    def self.perform
        puts "------------- BOOMERANG CRON -----------------"
        boom_gifts = []
        gs         = Gift.boomerangable
        count = gs.count
        puts "\n #{count}  boomerangable gifts\n"
        gs.each do |gift|
            new_gift    = GiftBoomerang.create({"old_gift_id" => gift.id})
            if new_gift.class == GiftBoomerang && new_gift.id.present?
                boom_gifts << new_gift
            end
        end
        puts "------------- #{boom_gifts.count}/#{count}  boomeranged gifts -----------------"

    end
end