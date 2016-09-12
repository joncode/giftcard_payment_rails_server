class GiftRedeemedEvent
    @queue = :after_save

    def self.perform gift_id, redemption_id=nil
    	puts "\n gift #{gift_id} / redemption #{redemption_id} is being GiftRedeemedEvent.job\n"
    	gift = Gift.find gift_id
    	puts Accountant.gift_redeemed_event(gift)
    	# puts PointsForCompletionJob.perform gift_id
    end
end