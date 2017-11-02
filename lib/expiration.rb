module Expiration

    def self.expire_gifts
        puts "------------- EXPIRE GIFTS CRON -----------------"
        expired_gifts = 0
        Gift.where(status: ["incomplete", "open", "notified"]).where.not(expires_at: nil).find_each do |gift|
            date = Time.now.utc.to_date

            if (date >= gift.expires_at.to_date)
                gift.expire_gift
                "-------------  Expired gift ID = #{gift.id}  -------------"
                expired_gifts += 1
            end
        end
        puts "------------- #{expired_gifts} expired gifts -----------------"
    end

    def self.destroy_sms_contacts
        puts "------------- DESTROY SMS CONTACTS CRON -----------------"
        destroyed_sms_contacts = 0
        SmsContact.where(gift_id: nil).where("created_at < ?", 1.day.ago).find_each do |contact|
            campaign_item = CampaignItem.where(textword: contact.textword).first
            contact.destroy unless campaign_item.live?
            puts "-------- Destroyed SMS Contact #{contact.id} --------"
            destroyed_sms_contacts += 1
        end
        puts "------------- #{destroyed_sms_contacts} SMS CONTACTS DESTROYED -----------------"
    end

    def self.destroy_expired_cards
        t = Time.now.utc
        if t.day == 2   # runs on the 2nd day of each month
            puts "------------- DESTROY EXPIRED CARDS CRON -----------------"
            cards_destroyed = 0
            m = t.month
            y = t.year

            cs = Card.where('year::int <  ? OR (month::int < ? AND year::int = ?)', y, m ,y)
            cs.each do |c|
                next c.year.to_s.length == 2
                c.destroy
                cards_destroyed += 1
            end
            puts "------------- #{cards_destroyed} EXPIRED CARDS DESTROYED -----------------"
        end
    end

end