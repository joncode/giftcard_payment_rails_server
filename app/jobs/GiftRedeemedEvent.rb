class GiftRedeemedEvent
    @queue = :after_save

    def self.perform gift_id
    	gift = Gift.find gift_id
    	Accountant.merchant(gift)
    	PointsForCompletionJob.perform gift_id
    end
end