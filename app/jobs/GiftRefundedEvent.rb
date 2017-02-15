class GiftRefundedEvent
    @queue = :after_save

    def self.perform gift_id
    	puts "\n gift #{gift_id} is in GiftRefundedEvent.job\n"
    	gift = Gift.unscoped.find gift_id

        rds = gift.redemptions.where(status: 'pending')
        rds.each do |r|
            r.run_operation 'cancel'
        end

    	if gift.pay_stat == 'refund_cancel'
	    	# if gift is refund_cancel
	    		# refund the gift registers
	    	registers = gift.registers
			registers.each {|r| r.reverse_charge }

    	elsif gift.pay_stat == 'refund_comp'
	    	# if gift is refund_live
	    		# leave the registers


    	end

    end
end