class GiftNotificationJob

	@queue = :push

    def self.perform args
    	return if ( args[:gift_id].to_i == 0 ) || ( ['invoice', 'receiver'].include?(args[:type]) )
    	gift = Gift.find args[:gift_id]
    	note_type = args[:type]

    	if note_type == 'invoice'
    		gift.invoice_giver
    	elsif note_type == 'receiver'
    		gift.notify_via_text
    		gift.send_receiver_notification
    	end
    end


end