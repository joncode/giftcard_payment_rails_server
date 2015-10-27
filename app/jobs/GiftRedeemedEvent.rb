class GiftRedeemedEvent
    @queue = :after_save

    def self.perform gift_id
    	puts "\n gift #{gift_id} is being GiftRedeemedEvent.job\n"
    	gift = Gift.find gift_id
    	puts Accountant.merchant(gift)
    	puts Accountant.affiliate_location(gift)
    	puts Accountant.affiliate_user(gift)
    	puts Accountant.affiliate_link(gift, gift.origin)
    	puts PointsForCompletionJob.perform gift_id
    end
end