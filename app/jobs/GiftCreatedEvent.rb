class GiftCreatedEvent
    @queue = :after_save

    def self.perform gift_id
    	puts "\n gift #{gift_id} is being GiftCreatedEvent.job\n"
    	gift = Gift.find gift_id
    	Accountant.merchant(gift)
    	begin
	        FacebookOps.notify_receiver_from_giver(gift)
    	rescue

    	end
    	PointsForSaleJob.perform gift_id
    end
end