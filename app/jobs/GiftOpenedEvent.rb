class GiftOpenedEvent
    @queue = :after_save

    def self.perform gift_or_gift_id, pushed_already=false
        puts "GiftOpenedEvent.rb\n"

        if gift_or_gift_id.class == Gift
            gift = gift_or_gift_id
            puts "gift = #{gift.id}\n"
        else
            gift = Gift.find(gift_or_gift_id)
        	puts "gift ID = #{gift_or_gift_id}\n"
        end

    	PushJob.perform(gift.id, 'gift_receiver_created_account')
    	gift.notify_receiver(false)

        if gift.cat == 300 && (gift.receiver.created_at - gift.created_at) <  30.minutes
            Alert.perform("GIFT_FRAUD_DETECTED_SYS", gift)
        end

        PointsForNewUserJob.perform([gift])
    end
end