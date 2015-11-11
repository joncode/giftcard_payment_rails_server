class GiftCreatedEvent
    @queue = :after_save

    def self.perform gift_id
    	puts "\n gift #{gift_id} is being GiftCreatedEvent.job\n"
    	gift = Gift.find gift_id
    	if gift.facebook_id.present?
    		FacebookOperations.graph_call(gift)
    	else
            oa = gift.oauth
            if oa.present? && oa.network == 'facebook'
                gift.update(facebook_id: oa.network_id)
                FacebookOperations.graph_call(gift)
            end
        end
    	Accountant.merchant(gift)
    	PointsForSaleJob.perform gift_id
    end
end