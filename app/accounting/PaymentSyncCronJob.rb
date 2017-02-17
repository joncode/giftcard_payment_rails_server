class PaymentSyncCronJob


    @queue = :subscription

    def self.perform
    	puts "PaymentSyncCronJob"
    	Payment.find_each do |payment|

    		if payment.status == 'HOLD'

    			# do nothing

    		elsif payment.partner_type == 'Merchant' && (payment.partner.mode == 'paused' || !payment.partner.active)

    			payment.update_column :status, 'HOLD'

    		end


    	end
	end



end