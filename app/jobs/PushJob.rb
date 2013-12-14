class PushJob

    @queue = :push

    def self.perform gift_id, thank_you=false
        gift        = Gift.find gift_id
        if thank_you
            push_receiver = gift.giver
            return nil unless push_receiver.respond_to?(:ua_alias)
            badge         = Gift.get_notifications(push_receiver)
            payload       = self.format_thank_you_payload(gift, push_receiver, badge)
        else
            receiver    = gift.receiver
            badge       = Gift.get_notifications(receiver)
            payload     = self.format_payload(gift, receiver, badge)
        end
        puts "SENDING PUSH NOTE for GIFT ID = #{gift_id} | #{payload}"
        resp        = Urbanairship.push(payload)
        puts "APNS push sent via ALIAS! #{resp}"

    end

private

    def self.format_payload(gift, receiver, badge)
        { :aliases => [receiver.ua_alias],:aps => { :alert => "#{gift.giver_name} sent you a gift at #{gift.provider_name}!", :badge => badge, :sound => 'pn.wav' },:alert_type => 1}
    end

    def self.format_thank_you_payload(gift, push_receiver, badge)
        { :aliases => [push_receiver.ua_alias],:aps => { :alert => "#{gift.receiver_name} opened your gift at #{gift.provider_name}!", :badge => badge, :sound => 'pn.wav' },:alert_type => 2}
    end

end