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
                    r.reverse_charge
                end
            end

            if gift.status == 'redeemed'
                if gift.notified_at.nil?
                    if gift.receiver_id.nil?
                        gift.update(status: 'incomplete', redeemed_at: nil, order_num: nil)
                    else
                        gift.update(status: 'open', redeemed_at: nil, order_num: nil)
                    end
                else
                    gift.update(status: 'notified' , redeemed_at: nil, order_num: nil)
                end
                if gift.merchant.redemption?
                    gift.redemptions.each do |redemption|
                        redemption.destroy
                    end
                end
                GiftAfterSaveJob.perform(gift)
            end
        	# puts PointsForCompletionJob.perform gift_id
        else
            puts "500 Internal - CANNOT UNREDEEM GIFT #{gift_id}"
        end
    end
end