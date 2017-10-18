class PushJob
    extend UrbanAirshipWrap

    @queue = :push

    def self.perform gift_id=nil, push_type='gift_receiver_notification', redemption_id=nil
        gift = Gift.find gift_id if gift_id
        redemption = Redemption.find redemption_id if redemption_id

        push_type = push_type.to_s
        case push_type
        when 'redemption_complete'
             push_receiver = redemption.receiver

            alert = "Your Redemption at #{redemption.merchant_name} is complete!"

        when 'gift_scheduled_notification'
            push_receiver = gift.receiver

            if gift.giver_type == "BizUser"
                alert = "#{gift.giver_name} sent you a gift! Scheduled to arrive on #{gift.schedule_time}"
            else
                alert = "#{gift.giver_name} sent you a gift at #{gift.provider_name}! Scheduled to arrive on #{gift.schedule_time}"
            end

        when 'gift_receiver_notification'
                # notify receiver of gift push
                # to gift receiver -> 'you have received a gift'
            push_receiver = gift.receiver

            if gift.giver_type == "BizUser"
                alert = "#{gift.giver_name} sent you a gift!"
            else
                alert = "#{gift.giver_name} sent you a gift at #{gift.provider_name}!"
            end

        when 'gift_receiver_created_account'
                # to gift giver -> 'gift is received - receiver created an account'
            push_receiver = gift.giver

            alert = "Thank You! #{gift.receiver_name} got the app and your gift!"

        when 'gift_received_thank_you'
                # to gift giver -> 'user (push_receiver) has looked at their gift'
            push_receiver = gift.giver

            alert = "#{gift.receiver_name} opened your gift at #{gift.provider_name}!"

        when 'gift_delivered'
            push_receiver = gift.giver

            alert = "Your gift has been delivered to #{gift.receiver_name} at #{gift.provider_name}!"

        else
            puts "500 Internal - Push Job received with wrong push type |#{push_type}| for GiftID = #{gift_id}"
        end

        return nil unless push_receiver.respond_to?(:ua_alias)

        self.send_push(push_receiver, alert, gift_id) if gift_id
        self.send_push(push_receiver, alert, nil, redemption_id) if redemption_id
        return true
    end

end
