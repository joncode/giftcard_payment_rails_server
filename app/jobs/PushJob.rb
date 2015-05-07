#require 'resque/plugins/resque_heroku_autoscaler'

class PushJob
    extend UrbanAirshipWrap
    #extend Resque::Plugins::HerokuAutoscaler

    @queue = :push

    def self.perform gift_id, thank_you=false, incomplete=false
        gift        = Gift.find gift_id
        if incomplete
                # to gift giver -> 'gift is received - receiver created an account'
            receiver = gift.giver
            return nil unless receiver.respond_to?(:ua_alias)
            payload  = self.format_incomplete_payload(gift, receiver)
        else
            if thank_you
                    # to gift giver -> 'user (receiver) has looked at their gift'
                receiver = gift.giver
                return nil unless receiver.respond_to?(:ua_alias)
                payload  = self.format_thank_you_payload(gift, receiver)
            else
                    # to gift receiver -> 'you have received a gift'
                receiver = gift.receiver
                payload  = self.format_payload_receiver(gift, receiver)
            end
        end
        puts "SENDING PUSH NOTE for GIFT ID = #{gift_id} | RECEIVER ID = #{receiver.id} | #{payload}"
        self.ua_push(payload, gift_id)
    end

private

    def self.format_payload_receiver(gift, receiver, badge=nil, android_tokens=[])
        if gift.giver_type == "BizUser"
            alert = "#{gift.giver_name} sent you a gift!"
        else
            alert = "#{gift.giver_name} sent you a gift at #{gift.provider_name}!"
        end
        self.format_payload(alert, receiver, 1, badge)
    end

    def self.format_thank_you_payload(gift, push_receiver, badge=nil)
        alert = "#{gift.receiver_name} opened your gift at #{gift.provider_name}!"
        self.format_payload(alert, push_receiver, 2, badge)
    end

    def self.format_incomplete_payload(gift, push_receiver, badge=nil)
        alert = "Thank You! #{gift.receiver_name} got the app and your gift!"
        self.format_payload(alert, push_receiver, 2, badge)
    end

end