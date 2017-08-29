class GiftRefundedEvent
    @queue = :after_save

    def self.perform gift_id
    	puts "\n gift #{gift_id} is in GiftRefundedEvent.job\n"
    	gift = Gift.unscoped.find gift_id

        if rf = gift.refund
            rf.set_and_save_usd_cents
        end

        rds = gift.redemptions.where(status: 'pending')
        rds.each do |r|
            r.run_operation 'cancel'
        end

    	if gift.pay_stat == 'refund_cancel'

	    	# if gift is refund_cancel
	    		# refund the gift registers
	    	registers = gift.registers
			registers.each {|r| r.reverse_charge }


            # partial Refund
                # determine the amount on the gift that must be paid out
                # run the register creation methods with the smaller amount
            if gift.partial_refund?
                Accountant.gift_partial_refund_event(gift)
            end

    	elsif gift.pay_stat == 'refund_comp'
	    	# if gift is refund_live
	    		# leave the registers


    	end

    end
end