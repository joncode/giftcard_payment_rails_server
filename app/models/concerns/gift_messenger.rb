module GiftMessenger
    extend ActiveSupport::Concern
    include Email

    def messenger(invoice=false)
        if self.success? && thread_on?
            Relay.send_push_notification(self)
            puts "#{self.class} -messenger- Notify Receiver via email #{self.receiver_name}"
            notify_receiver
            notify_admin if self.giver_type == "User"
            if invoice
                invoice_giver
            end
        end
    end

    def messenger_boomerang
        Relay.send_boomerang_push_notification(self)
        puts "#{self.class} -messenger- Notify Receiver via email #{self.receiver_name}"
        notify_receiver_boomerang
    end

    def messenger_proto_join
        Relay.send_push_notification(self)
        puts "#{self.class} -messenger- Notify Receiver via email #{self.receiver_name}"
        notify_receiver_proto_join
    end

end