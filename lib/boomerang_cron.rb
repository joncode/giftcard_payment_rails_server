module BoomerangCron

    def self.perform
        puts "------------- BOOMERANG CRON -----------------"
        boom_gifts = []
        boom_time  = Time.now.utc.to_date - 7.days
        gs         = Gift.where(status: 'incomplete').where('created_at < ?', boom_time)

        gs.each do |gift|
            new_gift    = GiftBoomerang.create({old_gift_id: gift.id})
            if new_gift.class == Gift && new_gift.id.present?
                boom_gifts << new_gift
            end
        end
        puts "------------- #{boom_gifts.count}/#{gs.count}  boomeranged gifts -----------------"

    end
end