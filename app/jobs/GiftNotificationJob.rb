class GiftNotificationJob

	@queue = :push

    def self.perform alert_type, gift_id
        puts "GiftNotificationJob -#{alert_type.inspect}- #{gift_id}"

    	gift = Gift.find gift_id

    	if alert_type == 'invoice'
    		gift.invoice_giver
    	elsif alert_type == 'receiver'
    		# gift.notify_via_text
    		gift.send_receiver_notification
    	else
            puts "500 Internal - BAD ALERT TYPE RECEIVED - #{alert_type} - GiftNotificationJob"
        end
    end


end