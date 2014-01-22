module Expiration

    def self.expire_gifts
        puts "------------- EXPIRE GIFTS CRON -----------------"
        expired_gifts = []
        gs = Gift.where(status: ["incomplete", "open", "notified"])
        gs = gs.select{ |gift| !gift.expires_at.nil? }
        gs.each do |gift|
            time = Time.now
            if (time - gift.expires_at) > 0
                gift.update(status: "expired")
                expired_gifts << gift
            end
        end
        puts "------------- #{expired_gifts.count} expired gifts -----------------"
    end

end