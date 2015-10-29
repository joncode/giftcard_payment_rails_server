class GiftDeactivatedEvent
    @queue = :after_save

    def self.perform gift_id, previous_gift_id=nil
    	puts "\n gift #{gift_id} is being GiftUnredeemEvent job\n"
    	gift = Gift.unscoped.find gift_id

        if ['incomplete', 'open', 'notified', 'cancel'].include?(gift.status)
            registers = Register.where(gift_id: gift_id)
            if registers.length == 0
                gift_parent = gift.parent

                if gift_parent.kind_of?(Gift) && gift_parent.id !== previous_gift_id
                    # regift of a another gift
                    self.perform(gift_parent.id, gift_id)
                end
            else
                registers.each {|r| r.payment.nil? ? r.destroy : r.create_credit }
                if gift.status != 'cancel'
                    gift.status = 'cancel'
                    gift.redeemed_at = Time.now.utc if gift.redeemed_at.nil?
                    gift.save
                    GiftAfterSaveJob.perform(gift)
                end
            end
        elsif gift.status == 'regifted'
            registers = Register.where(gift_id: gift_id)
            if registers.length == 0
                gift_parent = gift.parent
                if gift_parent.kind_of?(Gift) && gift_parent.id !== previous_gift_id
                    # regift of a another gift
                    self.perform(gift_parent.id, gift_id)
                else
                    # original gift, look for registers on children
                    regift = gift.child
                    self.perform(regift.id, gift_id)
                end
            else
                registers.each {|r| r.payment.nil? ? r.destroy : r.create_credit }
            end
        else
            # gift is already completed
            # redeemed, cancel, expired
        end

    	# puts PointsForCompletionJob.perform gift_id
    end
end