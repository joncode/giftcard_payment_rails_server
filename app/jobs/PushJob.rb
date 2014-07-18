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
                ios_payload       = self.format_thank_you_payload(gift, receiver, badge)
            else
                receiver        = gift.receiver
                tokens          = receiver.pn_tokens

                badge           = Gift.get_notifications(receiver)

                if tokens.where.not(platform: "android").present?
                    ios_payload     = self.format_payload(gift, receiver, badge)
                end
                if tokens.where(platform: "android").present?
                    android_tokens = tokens.where(platform: "android").map(&:pn_token)
                    android_payload = self.format_payload(gift, receiver, badge, android_tokens)
                end
            end
        else
            receiver = gift.giver
            return nil unless receiver.respond_to?(:ua_alias)
            badge         = Gift.get_notifications(receiver)
            ios_payload       = self.format_incomplete_payload(gift, receiver, badge)
        end

        if ios_payload.present?
            puts "SENDING IOS PUSH NOTE for GIFT ID = #{gift_id} | USER ID = #{receiver.id} | #{ios_payload}"
            self.ua_push(ios_payload, gift_id)
        end

        if android_payload.present?
            puts "SENDING ANDROID PUSH NOTE for GIFT ID = #{gift_id} | USER ID = #{receiver.id} | #{android_payload}"
            self.ua_push(android_payload, gift_id)
        end
    end

private

    def self.format_payload(gift, receiver, badge, android_tokens=[])
        if gift.giver_type == "BizUser"
            alert = "#{gift.giver_name} sent you a gift"
        else
            alert = "#{gift.giver_name} sent you a gift at #{gift.provider_name}!"
        end

###############################################
    #Master
    #     { :aliases => [receiver.ua_alias],:aps => { :alert => alert, :badge => badge, :sound => 'pn.wav' },:alert_type => 1}

    #QA Wednesday
    #     {
    #         :aliases => [receiver.ua_alias],
    #         :aps => {
    #             :alert => alert,
    #             :badge => badge,
    #             :sound => 'pn.wav' },
    #         :andrdoid => {
    #             :alert => alert
    #         },
    #         :alert_type => 1
    #     }

        if android_tokens.present?
            {
                :apids => android_tokens,
                :andrdoid => {
                    :alert => alert
                }
            }
        else
            {
                :aliases => [receiver.ua_alias],
                :aps => {
                    :alert => alert,
                    :badge => badge,
                    :sound => 'pn.wav'
                },
                :alert_type => 1
            }
        end
###############################################
    end

    def self.format_thank_you_payload(gift, push_receiver, badge)
        alert = "#{gift.receiver_name} opened your gift at #{gift.provider_name}!"
        {
            :aliases => [push_receiver.ua_alias],
            :aps => {
                :alert => alert,
                :badge => badge,
                :sound => 'pn.wav' },
            :alert_type => 2
        }
    end

    def self.format_incomplete_payload(gift, push_receiver, badge)
        alert = "Thank You! #{gift.receiver_name} got the app and your gift!"
        {
            :aliases => [push_receiver.ua_alias],
            :aps => {
                :alert => alert,
                :badge => badge,
                :sound => 'pn.wav' },
            :alert_type => 2
        }
    end

end