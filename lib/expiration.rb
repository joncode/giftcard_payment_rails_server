module Expiration

    def self.expire_gifts
        puts "------------- EXPIRE GIFTS CRON -----------------"
        expired_gifts = []
        gs = Gift.where(status: ["incomplete", "open", "notified"]).where.not(expires_at: nil)
        gs.each do |gift|
            date = Time.now.utc.to_date

            if (date > gift.expires_at.to_date)
                gift.update(status: "expired", redeemed_at: Time.now.utc)
                "-------------  Expired gift ID = #{gift.id}  -------------"
                expired_gifts << gift
            end
        end
        puts "------------- #{expired_gifts.count} expired gifts -----------------"
    end

end