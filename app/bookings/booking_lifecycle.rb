module BookingLifecycle
    include ActiveSupport::Concern

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
        if Rails.env.development?
            BookingEvent(self.id, 'customer_inquiry')
        else
            Resque.enqueue(BookingEvent, self.id, 'customer_inquiry')
        end
    end

    def send_purchase_link_to_customer
        if Rails.env.development?
            BookingEvent(self.id, 'merchant_confirms_date')
        else
            Resque.enqueue(BookingEvent, self.id, 'merchant_confirms_date')
        end
    end

    def booking_confirmed
        if Rails.env.development?
            BookingEvent(self.id, 'customer_purchase_complete')
        else
            Resque.enqueue(BookingEvent, self.id, 'customer_purchase_complete')
        end
    end

    def send_reminder(days_till)
        if Rails.env.development?
            BookingEvent(self.id, 'send_reminder', days_till)
        else
            Resque.enqueue(BookingEvent, self.id, 'send_reminder', days_till)
        end
    end



end