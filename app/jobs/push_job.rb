class PushJob
    extend UrbanAirshipWrap

    @queue = :push

    def self.perform gift_id, thank_you=false, incomplete=false
        gift = Gift.find gift_id

        push_type = :gift_receiver_notification
        push_type = :gift_receiver_created_account if incomplete
        push_type = :gift_received_thank_you if thank_you

        case push_type
        when :gift_receiver_notification
                # notify receiver of gift push
                # to gift receiver -> 'you have received a gift'
            receiver = gift.receiver
            return nil unless receiver.respond_to?(:ua_alias)

            if gift.giver_type == "BizUser"
                alert = "#{gift.giver_name} sent you a gift!"
            else
                alert = "#{gift.giver_name} sent you a gift at #{gift.provider_name}!"
            end

        when :gift_receiver_created_account
                # to gift giver -> 'gift is received - receiver created an account'
            receiver = gift.giver
            return nil unless receiver.respond_to?(:ua_alias)

            alert = "Thank You! #{gift.receiver_name} got the app and your gift!"

        when :gift_received_thank_you
                # to gift giver -> 'user (receiver) has looked at their gift'
            receiver = gift.giver
            return nil unless receiver.respond_to?(:ua_alias)

            alert = "#{gift.receiver_name} opened your gift at #{gift.provider_name}!"
        end
        puts "SENDING PUSH NOTE for GIFT ID = #{gift_id} | RECEIVER ID = #{receiver.id} | #{alert}"
        self.send_push(receiver, alert, gift_id)
        return true
    end

end
