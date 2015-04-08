class GiftCreatedEvent
    @queue = :after_save

    def self.perform gift_id
    	puts "\n gift #{gift_id} is being GiftCreatedEvent.job\n"
    	gift = Gift.find gift_id
    	Accountant.merchant(gift)
    	Accountant.affiliate_location(gift)
    	Accountant.affiliate_user(gift)
    	PointsForSaleJob.perform gift_id
    end
end