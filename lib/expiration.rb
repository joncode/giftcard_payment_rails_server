module Expiration

    def self.expire_gifts
        puts "------------- EXPIRE GIFTS CRON -----------------"
        expired_gifts = 0
        Gift.where(status: ["incomplete", "open", "notified"]).where.not(expires_at: nil).find_each do |gift|
            date = Time.now.utc.to_date

            if (date > gift.expires_at.to_date)
                gift.update(status: "expired", redeemed_at: Time.now.utc)
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

end