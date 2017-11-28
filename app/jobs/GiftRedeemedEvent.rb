class GiftRedeemedEvent
    @queue = :after_save

    def self.perform gift_id, redemption_id=nil
    	puts "\n gift #{gift_id} / redemption #{redemption_id} is being GiftRedeemedEvent.job\n"
    	gift = Gift.find gift_id
    	puts Accountant.gift_redeemed_event(gift)
    	if gift.status == 'redeemed' || gift.balance == 0
	    	gift.cancel_all_pending_redemptions
		end

    	# puts PointsForCompletionJob.perform gift_id
    end
end