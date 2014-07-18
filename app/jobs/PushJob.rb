class PushJob
    extend UrbanAirshipWrap

    @queue = :push

    def self.perform gift_id, thank_you=false, incomplete=false
        gift        = Gift.find gift_id
        if !incomplete
            if thank_you
                receiver = gift.giver
                return nil unless receiver.respond_to?(:ua_alias)
                badge         = Gift.get_notifications(receiver)
                payload       = self.format_thank_you_payload(gift, receiver, badge)
            else
                receiver        = gift.receiver
                badge           = Gift.get_notifications(receiver)
                payload         = self.format_payload(gift, receiver, badge)
            end
        else
            receiver = gift.giver
            return nil unless receiver.respond_to?(:ua_alias)
            badge         = Gift.get_notifications(receiver)
            payload       = self.format_incomplete_payload(gift, receiver, badge)
        end
        puts "SENDING PUSH NOTE for GIFT ID = #{gift_id} | RECEIVER ID = #{receiver.id} | #{payload}"
        self.ua_push(payload, gift_id)
    end

private

    def self.format_payload(gift, receiver, badge, android_tokens=[])
        if gift.giver_type == "BizUser"
            alert = "#{gift.giver_name} sent you a gift"
        else
            alert = "#{gift.giver_name} sent you a gift at #{gift.provider_name}!"
        end
        {
            :aliases => [receiver.ua_alias],
            :aps => {
                :alert => alert,
                :badge => badge,
                :sound => 'pn.wav'
            },
            :alert_type => 1,
            :android => {
                :alert => alert
            }
        }
    end

    def self.format_thank_you_payload(gift, push_receiver, badge)
        alert = "#{gift.receiver_name} opened your gift at #{gift.provider_name}!"
        {
            :aliases => [push_receiver.ua_alias],
            :aps => {
                :alert => alert,
                :badge => badge,
                :sound => 'pn.wav'
            },
            :alert_type => 2,
            :android => {
                :alert => alert
            }
        }
    end

    def self.format_incomplete_payload(gift, push_receiver, badge)
        alert = "Thank You! #{gift.receiver_name} got the app and your gift!"
        {
            :aliases => [push_receiver.ua_alias],
            :aps => {
                :alert => alert,
                :badge => badge,
                :sound => 'pn.wav'
            },
            :alert_type => 2,
            :android => {
                :alert => alert
            }
        }
    end

end