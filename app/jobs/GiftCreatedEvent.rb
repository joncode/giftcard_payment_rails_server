class GiftCreatedEvent

    @queue = :after_save

    def self.perform gift_id
    	puts "\n gift #{gift_id} is being GiftCreatedEvent.job\n"
    	gift = Gift.find gift_id
        if gift.pay_stat != "payment_error"
            Accountant.gift_created_event(gift)

            notify_via_facebook gift
            notify_via_text gift

            PointsForSaleJob.perform gift_id
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

    def self.notify_via_text gift
        if !gift.receiver_phone.blank?
            msg = "#{gift.giver_name} has sent you a #{gift.value_s} eGift Card
at #{gift.merchant_name} with ItsOnMe® - the eGifting app.\n
Click here to claim your gift.\n #{gift.invite_link}"
            resp = OpsTwilio.text to: gift.receiver_phone, msg: msg
        end
    end

end

