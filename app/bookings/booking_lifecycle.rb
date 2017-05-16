module BookingLifecycle
    include ActiveSupport::Concern


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