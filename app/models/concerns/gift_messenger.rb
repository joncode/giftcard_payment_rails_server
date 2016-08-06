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

    def messenger_promo_gift_scheduled
        if !self.receiver_phone.blank?
            msg = "#{self.giver_name} has sent you a #{self.value_s} eGift Card
at #{self.merchant_name} with ItsOnMe® - the eGifting app.\n
The gift is scheduled to arrive on #{self.scheduled.to_formatted_s(:only_date)}\n
Use this phone number when you make your account to connect the gift\n
Click here to download the app.\n #{PUBLIC_URL}/download"
            resp = OpsTwilio.text to: self.receiver_phone, msg: msg
        elsif !self.receiver_email.blank?
             msg = "<h2>#{self.giver_name} has sent you a #{self.value_s} eGift Card
at #{self.merchant_name} with ItsOnMe® - the eGifting app.</h2>
<p>The gift is scheduled to arrive on #{self.scheduled.to_formatted_s(:only_date)}</p>
<p>Use this email when you make your account to connect the gift</p>
<p>Click here to download the app. #{PUBLIC_URL}/download</p>"
            email_data_hsh = {
                "subject" => "ItsOnMe Promotional Gift",
                "html"    => "<div>#{msg}</div>".html_safe,
                "email"   => self.receiver_email
            }
            puts email_data_hsh.inspect
            email_obj = EmailAlerts.new(email_data_hsh)
            res = email_obj.send_email
        else
            # facebook pre-notify not available yet
        end
    end

end