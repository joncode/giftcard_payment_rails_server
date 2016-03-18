class GiftCreatedEvent
    @queue = :after_save

    def self.perform gift_id
    	puts "\n gift #{gift_id} is being GiftCreatedEvent.job\n"
    	gift = Gift.find gift_id
    	Accountant.gift_created_event(gift)
        begin
            res = FacebookOps.notify_receiver_from_giver(gift)
            puts "Facebook reponse #{res.inspect}"
        rescue => e
            puts "500 Internal GiftCreatedEvent failed on facebook #{e.inspect}"
        end
    	PointsForSaleJob.perform gift_id
    end
end