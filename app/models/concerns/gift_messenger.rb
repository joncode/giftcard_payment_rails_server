module GiftMessenger
    extend ActiveSupport::Concern
    include Email

    def messenger(invoice=false)
        if self.success? && thread_on?
            puts "#{self.class} -messenger- Notify Receiver via email #{self.receiver_name}"

            send_receiver_notification if self.status != 'schedule'

            notify_admin if self.giver_type == "User"
            if invoice
                invoice_giver
            end
        end
    end

    def send_receiver_notification
        Relay.send_push_notification(self)
        notify_receiver
    end

    def send_gift_delivered_notifications
        Relay.send_gift_delivered(self)
        send_receiver_notification
    end

    def send_internal_email
        notify_developers
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

    def invite_link
        "#{PUBLIC_URL}/signup/acceptgift?id=#{self.obscured_id}"
    end

end