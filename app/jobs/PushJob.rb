class PushJob

    @queue = :push

    def self.perform gift_id

        if true || Rails.env.production? || Rails.env.staging?
            gift        = Gift.find gift_id
            receiver    = gift.receiver
            badge       = Gift.get_notifications(receiver)
            payload     = self.format_payload(gift, receiver, badge)
            puts "SENDING PUSH NOTE for GIFT ID = #{gift_id}"
            resp        = Urbanairship.push(payload)
            puts "APNS push sent via ALIAS! #{resp}"
        end
    end

private

    def self.format_payload(gift, receiver, badge)
        { :aliases => [receiver.ua_alias],
            :aps => { :alert => "#{gift.giver_name} sent you a gift at #{gift.provider_name}!", :badge => badge, :sound => 'pn.wav' },
            :alert_type => 1
        }
    end
    
end