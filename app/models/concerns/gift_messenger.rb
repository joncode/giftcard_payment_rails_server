module GiftMessenger
    extend ActiveSupport::Concern

    def messenger(invoice=false)
        if self.success? && thread_on?
            Relay.send_push_notification(self)
            puts "#{self.class} -messenger- Notify Receiver via email #{self.receiver_name}"
            notify_receiver
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
end