class GiftSettledEvent

	@queue = :database

    def self.perform payment_id

    	payment = Payment.find(payment_id)

    	if payment.paid

    		# get all gifts for payments
    		# settle the gifts where all the registers are in
    		payment.gifts.each do |gift|

    			if gift.status == 'redeemed'
    				gift.update(pay_stat: 'settled')
    			end

    		end

    	end

    end


end

