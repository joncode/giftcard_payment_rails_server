class GiftUnredeemEvent
    @queue = :after_save

    def self.perform gift_id
    	puts "\n gift #{gift_id} is being GiftUnredeemEvent job\n"
    	gift = Gift.unscoped.find gift_id

        if ['redeemed', 'notified'].include?(gift.status)
            Register.where(gift_id: gift_id).each do |r|
                if gift.merchant.creation? && r.loc?
                    next
                else
                    if r.payment.nil?
                        r.destroy
                    else
                        r.create_credit
                    end
                end
            end
            if gift.status == 'redeemed'
                gift.update(status: 'notified' , redeemed_at: nil, order_num: nil)
                GiftAfterSaveJob.perform(gift)
            end
        	# puts PointsForCompletionJob.perform gift_id
        else
            puts "500 Internal - CANNOT UNREDEEM GIFT #{gift_id}"
        end
    end
end