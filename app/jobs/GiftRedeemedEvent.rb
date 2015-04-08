class GiftRedeemedEvent
    @queue = :after_save

    def self.perform gift_id
    	puts "\n gift #{gift_id} is being GiftRedeemedEvent.job\n"
    	gift = Gift.find gift_id
    	Accountant.merchant(gift)
    	PointsForCompletionJob.perform gift_id
    end
end