module GiftScheduler
    extend ActiveSupport::Concern


    def schedule_gift
    	# see if user info has an account
    	self.find_receiver

    	if self.receiver.present?
	    	self.status = 'open'
	    else
	    	self.status = 'incomplete'
	    end
	    if save
		    messenger(:invoice_giver)
		    true
		else
			false
		end
	rescue => e
		"500 Internal - Scheduled gift failed #{self.id} #{e.inspect}"
    end

end