class BookingEvent

    @queue = :push

    def self.perform booking_id, event_name, data=nil

        puts "BookingEvent #{booking_id} - event name #{event_name}"

        case event_name.to_s

        when 'customer_inquiry'
            BookingNotifications.send_inquiry_confirmation_to_customer booking_id
        when 'merchant_confirms_date'
            BookingNotifications.send_purchase_link_to_customer booking_id
        when 'customer_purchase_complete'
            BookingNotifications.send_booking_confirmation_to_customer booking_id
        when 'send_reminder'
            BookingNotifications.send_email_reminder booking_id, data
        else
            puts "500 Internal - unknown event name #{event_name}"
            raise "Unknown BookingEvent #{event_name}"
        end

    end

end



# API - customer submits inquiry
    # email customer confirmation
    # send Alert to IOM concierge team
    # send inquiry alert to Merchant

# HUMAN - merchant contacted to confirm booking

# ADMT - merchant confirms booking date
    # generate booking link and send to customer to complete purchase

