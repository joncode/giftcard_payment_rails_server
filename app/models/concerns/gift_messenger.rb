module GiftMessenger
    extend ActiveSupport::Concern
    include Email

    def messenger(invoice=false, thread_it=true)
        if self.success? && thread_on?
            puts "#{self.class} -messenger- Notify Receiver via email #{self.receiver_name} #{self.receiver_email}"

            # notify_admin if self.giver_type == "User"
            send_receiver_notification(thread_it) if self.status != 'schedule'
            if invoice
                invoice_giver(thread_it)
            end
        else
            puts "500 Internal Gift messenger FAIL conditional #{self.id} #{self.success?} #{thread_on?}"
        end
    end

    def send_receiver_notification(thread_it=true)
        puts "send_receiver_notification"
        Relay.send_push_notification(self)
        notify_receiver(thread_it)
    end

    def send_gift_delivered_notifications
        if self.payable == "Proto"
            messenger_proto_join
            notify_via_text
        else
            Relay.send_gift_delivered(self)
            send_receiver_notification
            notify_via_text
        end
    end

    def notify_via_text_old
        if !self.receiver_phone.blank?
            puts "texting the gift receiver for #{self.id}"
            if self.partner == Affiliate.find(GOLDEN_GAMING_ID)
                msg = "Your friend, #{self.giver_name}, sent you a gift at PT's. Download or open the app to claim: https://pteglvapp.com/download/iom"
            else
                msg = "#{self.giver_name} has sent you a #{self.value_s} gift card
at #{self.merchant_name}.\n
Click here for your gift.\n #{self.invite_link}"
            end
            resp = OpsTwilio.text to: self.receiver_phone, msg: msg
        end
    end

    def notify_via_text
        if !self.receiver_phone.blank?
            puts "link texting the gift receiver for #{self.id}"
            if self.partner == Affiliate.find(GOLDEN_GAMING_ID)
                msg = "Your friend, #{self.giver_name}, sent you a gift at PT's. Download or open the app to claim: https://pteglvapp.com/download/iom"
                resp = OpsTwilio.text to: self.receiver_phone, msg: msg
            else
                sys_msg = "Click ^here^ for your gift.\n #{self.giver_name} has sent you a #{self.value_s} gift card
at #{self.merchant_name}."
                resp = OpsTwilio.link_text to: self.receiver_phone, link: self.invite_link, usr_msg: self.message, system_msg: sys_msg
            end
        end
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
        # notify_via_text
        notify_receiver_proto_join
    end

    def schedule_time
        TimeGem.change_time_to_zone(self.scheduled_at, self.merchant.timezone).to_formatted_s(:only_date)
    end

    def messenger_promo_gift_scheduled
        # Relay.send_scheduled_gift_notification(self)

        if self.receiver_id && self.receiver

            rec = self.receiver
            if !rec.phone.blank?

                msg = "#{self.giver_name} has sent you a #{self.value_s} eGift Card
at #{self.merchant_name} with ItsOnMe®\n
The gift is scheduled to arrive on #{schedule_time}"
                resp = OpsTwilio.text to: rec.phone, msg: msg

            else

                 msg = "<h2>#{self.giver_name} has sent you a #{self.value_s} eGift Card
at #{self.merchant_name} with ItsOnMe®</h2>
<p>The gift is scheduled to arrive on #{schedule_time}</p>
#{cta_button}"
                email_data_hsh = {
                    "subject" => "ItsOnMe Promotional Gift",
                    "html"    => "<div>#{msg}</div>".html_safe,
                    "email"   => rec.email
                }
                puts email_data_hsh.inspect
                email_obj = EmailAlerts.new(email_data_hsh)
                res = email_obj.send_email
            end

        elsif !self.receiver_phone.blank?

            msg = "#{self.giver_name} has sent you a #{self.value_s} eGift Card
at #{self.merchant_name} with ItsOnMe® - the eGifting app.\n
The gift is scheduled to arrive on #{schedule_time}\n
Use this phone number when you make your account to connect the gift\n
Click here to download the app.\n #{CLEAR_CACHE}/download"
            resp = OpsTwilio.text to: self.receiver_phone, msg: msg

        elsif !self.receiver_email.blank?

             msg = "<h2>#{self.giver_name} has sent you a #{self.value_s} eGift Card
at #{self.merchant_name} with ItsOnMe® - the eGifting app.</h2>
<p>The gift is scheduled to arrive on #{schedule_time}</p>
<p>Use this email when you make your account to connect the gift</p>
<p>Click here to download the app</p>
#{cta_button}"
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

    def cta_button
        "<table border='0' cellspacing='0' cellpadding='0' width='300' align='center' style='margin: 15px auto; border: 2px solid #fff; border-radius: 6px; max-width: 300px;'>
<tr><td bgcolor='#3bb1d9' align='center' style='font-family:'Trebuchet MS', Verdana, sans-serif;font-size:24px;padding: 10px 5px;'>
<a href='#{CLEAR_CACHE}/download' target='_blank' style='color:#fff;display:inline-block;width:90%;padding: 5px 5px;text-transform:uppercase;font-weight:bold;color:#fff;text-decoration:none!important;'>Download App</a>
</td></tr></table>".html_safe
    end

end