module GiftMessenger
    extend ActiveSupport::Concern
    include Email
    include EnglishHelper

    def messenger(invoice=false, thread_it=true)
        if self.success? && thread_on?
            _args = {invoice:invoice, thread_it:thread_it}.reject{|_,v| !v}.keys.join(', ')
            _signature = "[GiftMessenger(#{self.hex_id}) :: messenger(#{_args})]"

            # notify_admin if self.giver_type == "User"
            if self.status != 'schedule'
                puts "\n#{_signature}  Sending receiver notification to #{self.receiver_name}"
                send_receiver_notification(thread_it)
            end
            if invoice
                # From Mailers/Email
                puts "\n#{_signature} -> invoice_giver()"
                invoice_giver(thread_it)
            end
        else
            puts "500 Internal Gift messenger FAIL conditional #{self.id} #{self.success?} #{thread_on?}"
        end
    end

    def send_receiver_notification(thread_it=true)
        _args = (thread_it ? "thread_it" : '')
        puts "\n\n[GiftMessenger(#{self.hex_id}) :: send_receiver_notification(#{_args})]  Sending push notification, email, text"
        Relay.send_push_notification(self)

        notify_receiver(thread_it)  # Notify via email, if present
        notify_via_text
    end

    def send_gift_delivered_notifications
        _signature = "[GiftMessenger(#{self.hex_id}) :: send_gift_delivered_notifications]"

        if self.payable == "Proto"
            puts "\n\n#{_signature}  (Proto) Sending push notification, email, text"
            messenger_proto_join
            notify_via_text
        else
            puts "\n\n#{_signature}  Sending delivery notification, and receiver email+text"
            Relay.send_gift_delivered(self)
            send_receiver_notification
        end
    end

    def notify_via_text
        _signature = "[GiftMessenger(#{self.hex_id}) :: notify_via_text]"
        puts "\n\n#{_signature}"
        if !self.receiver_phone.blank?
            if self.partner == Affiliate.find(GOLDEN_GAMING_ID)
                puts "\n#{_signature}  (PT's) Texting #{self.receiver_phone}"
                msg = "Your friend, #{self.giver_name}, sent you a gift at PT's. Download or open the app to claim: https://pteglvapp.com/download/iom"
                resp = OpsTwilio.text to: self.receiver_phone, msg: msg
            else
                usr_msg = nil
                # `self.title` refers to gift#title
                sys_msg = "#{self.giver_name} has sent you #{a self.title} at #{self.merchant_name}."
                # Append a newline to `link_msg`, followed by the user message here to prevent iOS 11 from inserting a "Tap to load preview" message.
                link_msg  = "Tap the link to accept your gift: #{self.invite_link}\n\n"
                suffix    = "Enjoy!"
                suffix    = "'#{self.message}' -#{self.giver_name}"  unless self.message.blank?
                link_msg += suffix

                media_url = nil
                begin
                    # This is in a try/catch because the shoppingCart data doesn't always want to parse.
                    item = JSON.parse(self.shoppingCart).first
                    item = MenuItem.find(item["item_id"])
                    # Pluck out the item's photo and apply our transformation
                    # The "b_rgb" (b for background) here is due to a Cloudinary bug: b_rgb is ignored when present in transformation, so we must apply it separately.
                    media_url = item.photo.split("upload").join("upload/b_rgb:00141c,t_MMS%20gifting%20vignette")  rescue nil
                rescue => e
                    # `_signature` contains the gift id, which should be sufficient for investigating
                    puts "\n#{_signature}  Error while extracting photo url for MMS"
                    puts " | Error details: #{e.inspect}"
                    media_url = nil
                end

                puts "\n#{_signature}  #{media_url ? "MMS" : "SMS"} Texting #{self.receiver_phone}"
                resp = OpsTwilio.link_text to: self.receiver_phone, link: link_msg, usr_msg: usr_msg, system_msg: sys_msg, media_url: media_url
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

                msg = "#{self.giver_name} has sent you #{a self.title}
at #{self.merchant_name} with ItsOnMe®\n
The gift is scheduled to arrive on #{schedule_time}"
                resp = OpsTwilio.text to: rec.phone, msg: msg

            else

                 msg = "<h2>#{self.giver_name} has sent you #{a self.title}
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

            msg = "#{self.giver_name} has sent you #{a self.title}
at #{self.merchant_name} with ItsOnMe® - the eGifting app.\n
The gift is scheduled to arrive on #{schedule_time}\n
Use this phone number when you make your account to connect the gift\n
Click here to download the app.\n #{CLEAR_CACHE}/download"
            resp = OpsTwilio.text to: self.receiver_phone, msg: msg

        elsif !self.receiver_email.blank?

             msg = "<h2>#{self.giver_name} has sent you #{a self.title}
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