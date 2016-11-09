module GiftScheduler
    extend ActiveSupport::Concern


    def deliver_now
    	# see if user info has an account
    	self.find_receiver

    	if self.receiver.present?
	    	self.status = 'open'
	    else
	    	self.status = 'incomplete'
	    end
	    if save
	    	puts "Gift has been scheduled for delivery #{self.status} #{self.id}"
		    messenger(:invoice_giver)
		    true
		else
			puts "500 Internal - Gift deliver now failed #{self.id} #{self.errors.messages}"
			false
		end
	rescue => e
		"500 Internal - Scheduled gift failed #{self.id} #{e.inspect}"
    end

end