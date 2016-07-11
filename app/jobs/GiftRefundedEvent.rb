class GiftRefundedEvent
    @queue = :after_save

    def self.perform gift_id
    	puts "\n gift #{gift_id} is in GiftRefundedEvent.job\n"
    	gift = Gift.unscoped.find gift_id

    	if gift.pay_stat == 'refund_cancel'
	    	# if gift is refund_cancel
	    		# refund the gift registers
	    	registers = gift.registers
			registers.each do |r|
                reg = r.reverse_charge
                puts "Here is the register #{reg.inspect}"
            end

    	elsif gift.pay_stat == 'refund_comp'
	    	# if gift is refund_live
	    		# leave the registers

    	end

    end
end