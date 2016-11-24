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
	    puts "IN DELIVER NOW #{self.id} - #{self.status}"
	    if save
		    puts "SAVED DELIVER NOW #{self.id} - #{self.status}"
		    messenger(:invoice_giver, false)
		    true
		else
			puts "500 Internal - Gift deliver now failed #{self.id} #{self.errors.messages}"
			false
		end
	rescue => e
		puts "500 Internal - Scheduled gift failed #{self.id} #{e.inspect}"
    end

end