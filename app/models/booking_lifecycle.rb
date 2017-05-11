module BookingLifecycle
    extend ActiveSupport::Concern

#   -------------  CLASS API SURFACE

    def self.reminders
    	Booking.where(active: true, status: 'complete').where.not(event_at: nil).find_each do |booking|
    		dt = DateTime.now.utc
    		[7,1].each do |d|

    			if booking.event_at < d.days.ago && booking.event_at > (d +1).days.ago

    				puts "BookingLifecycle.reminder (11) - reminder for booking #{booking.id}"
    				if booking.merchant && booking.merchant.active_live?
    					booking.send_reminder(d)
    				else
    					puts "500 Internal - booking #{booking.id} Reminder at inactive merchant"
    				end
    			end
    		end
    	end
    end

#   -------------  INSTANCE API SURFACE

    def customer_submits_inquiry
			# send email to customer confirming that we have received their inquiry
			# Send Alert to IOM team that inquiry has occurred
			# Send Alert to the Merchant that inquiry has occurred ?
    	EmailBooking.send_inquiry_confirmation_to_customer self.id
    end

    def send_purchase_link_to_customer
    	EmailBooking.send_purchase_link_to_customer self.id
    end

    def booking_confirmed
		# send email to customer receipt - confirming purchase
		# Send Alert to IOM team that inquiry has occurred
		# Send Alert to the Merchant that inquiry has occurred ?
		EmailBooking.send_booking_confirmation_to_customer self.id
    end

    def send_reminder(days_till)
    	EmailBooking.send_email_reminder self.id, days_till
    end



end