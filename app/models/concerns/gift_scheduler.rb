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
	    if self.save
		    send_gift_delivered_notifications
		    true
		else
			false
		end
    end

end