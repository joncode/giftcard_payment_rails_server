class GiftUnredeemEvent
    @queue = :after_save

    def self.perform gift_id
    	puts "\n gift #{gift_id} is being GiftUnredeemEvent job\n"
    	gift = Gift.find gift_id

        registers = Register.where(gift_id: gift_id)
        registers.each do |r|
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
    	puts PointsForCompletionJob.perform gift_id
    end
end