class GiftCreatedEvent
    @queue = :after_save

    def self.perform gift_id
    	puts "\n gift #{gift_id} is being GiftCreatedEvent.job\n"
    	gift = Gift.find gift_id
    	Accountant.gift_created_event(gift)

        notify_via_facebook gift
        notify_via_text gift

    	PointsForSaleJob.perform gift_id
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
            msg = "You've received a Gift!\n#{gift.invite_link}"
            resp = OpsTwilio.text to: gift.receiver_phone, msg: msg
        end
    end

end