class GiftCreatedEvent

    @queue = :after_save

    def self.perform gift_id
    	puts "\n gift #{gift_id} is being GiftCreatedEvent.job\n"
    	gift = Gift.find gift_id

        if gift.pay_stat != "payment_error"
            Accountant.gift_created_event(gift)

            unless gift.status == 'schedule'
                notify_via_facebook gift
                gift.notify_via_text
            end

            # PointsForSaleJob.perform gift_id
            if gift.cat == 300
                Alert.perform("GIFT_PURCHASED_SYS", gift)
                Alert.perform("GIFT_PURCHASED_MT", gift)
            end
        end
    end

    def self.notify_via_facebook gift
        begin
            res = OpsFacebook.notify_receiver_from_giver(gift)
            puts "Facebook reponse #{res.inspect}"
        rescue => e
            puts "500 Internal (GiftCreatedEvent) failed on facebook #{e.inspect}"
        end
    end

end

