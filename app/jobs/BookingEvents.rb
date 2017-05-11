class BookingEvent
    @queue = :after_save

    def self.perform booking_id, event_name
        case event_name.to_s

        when 'customer_inquiry'

        when 'merchant_confirms_date'

        when 'customer_purchase_complete'

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

