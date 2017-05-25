module Emailer
    include EmailHelper

    # Account Emails
    def reset_password data
        if data['user_type'] == 'AtUser'
            user = AtUser.find(data["user_id"])
        elsif data['user_type'] == 'MtUser'
            user = MtUser.find(data["user_id"])
        else
            user = User.find(data["user_id"])
        end
        subject  = "Reset password request"
        body     = text_for_user_reset_password(user, data['token'], data['subdomain'])

        template_name = "user"
        email_address = data["email"] || user.email
        message       = message_hash(subject, email_address, user.name, body)
        request_mandrill_with_template(template_name, message, [data["user_id"], user.class.name])
    end

    def confirm_email data
        user    = User.find(data["user_id"])
        subject = "Confirm your email address"
        body    = text_for_user_confirm_email(user, data["link"])
        bcc     = "info@itson.me"

        template_name = "user"
        message       = message_hash(subject, user.email, user.name, body, bcc)
        request_mandrill_with_template(template_name, message, [data["user_id"], "User"])
    end

    def welcome_from_dave data
        user      = User.find(data["user_id"])
        text      = text_for_welcome_from_dave(user)
        message   = {
            "subject"     => "Please share your feedback",
            "from_name"   => "David Leibner",
            "from_email"  => "david.leibner@itson.me",
            "text"        => text,
            "to"          => [{
                "email" => user.email,
                "name"  => user.name
            }]
        }
        request_mandrill_with_message(message, [data["user_id"], "User"])
    end

####### Gift Emails

    def notify_receiver data
        template = GiftTemplateMainMailer.new(data["gift_id"])
        template.notify_receiver
    end

    def remind_receiver data
        template = GiftTemplateMainMailer.new(data["gift_id"], :reminder)
        template.notify_receiver
    end

    def notify_receiver_proto_join data
        template = GiftTemplateMainMailer.new(data["gift_id"])
        template.notify_receiver
    end


    def notify_receiver_boomerang data
        template = BoomerangMailer.new(data["gift_id"])
        template.notify_receiver
    end

    def invoice_giver data
        gift    = Gift.find(data["gift_id"])
        return if gift.giver_type != 'User'
        subject = "Gift purchase receipt"
        email   = gift.giver.email
        name    = gift.giver_name
        body    = text_for_invoice_giver(gift)

        template_name = "user"
        message       = message_hash(subject, email, name, body)
        request_mandrill_with_template(template_name, message, [data["gift_id"], "Gift"])
    end

    def reminder_hasnt_gifted data
        user    = User.find(data["user_id"])
        subject = "Make someone's day"
        email   = user.email
        name    = user.name
        body    = text_for_reminder_hasnt_gifted(user)

        template_name = "user"
        message       = message_hash(subject, email, name, body)
        request_mandrill_with_template(template_name, message, [user.id, "User"])
    end

##### Merchant Tools

    # {"text"=>"affiliate_invite", "email"=>"jon.gutwillig@itson.me", "affiliate_id"=>1, "merchant_id"=>1,
    # "company_type" => 'Affiliate', "token"=>"CjmuXCeZiz0mYGtooOSMOQ"}

    def affiliate_invite data
        find_id = data['affiliate_id'] || data['merchant_id']
        affiliate = Affiliate.find(find_id)
        subject  = "Welcome to ItsOnMe - Partner Tools"
        email    = data["email"]
        name     = "#{affiliate.name} Staff"
        body     = text_for_affiliate_invite(affiliate, data["token"])
        bcc      = bcc_company_email

        template_name = "merchant"
        message       = message_hash(subject, email, name, body, bcc)
        request_mandrill_with_template(template_name, message, [affiliate.id, "Affiliate"])
    end

    def merchant_invite data
        merchant = Merchant.unscoped.find(data["merchant_id"])
        subject  = "Welcome to ItsOnMe - Merchant Tools"
        email    = data["email"]
        name     = "#{merchant.name} Staff"
        body     = text_for_merchant_invite(merchant, data["token"])
        bcc      = bcc_company_email

        template_name = "merchant"
        message       = message_hash(subject, email, name, body, bcc)
        request_mandrill_with_template(template_name, message, [merchant.id, "Merchant"])
    end

    def merchant_staff_invite data
        if data['company_type'] == "Affiliate"
            affiliate_invite data
        else
            merchant     = Merchant.unscoped.find(data["merchant_id"])
            invitor_name = data["invitor_name"]
            invite_token = data["token"]
            subject      = "Welcome to ItsOnMe - Merchant Tools"
            email        = data["email"]
            name         = "#{merchant.name} Staff"
            body         = text_for_merchant_staff_invite(merchant, invitor_name, invite_token)
            bcc          = bcc_company_email

            template_name = "merchant"
            message       = message_hash(subject, email, name, body, bcc)
            request_mandrill_with_template(template_name, message, [merchant.id, "Merchant"])
        end
    end

    def merchant_signup_welcome full_data_obj
        data = full_data_obj["args"]
        puts "\n Emailer merchant_signup_welcome #{data.inspect}"
        # merchant = MerchantSignup.find(data["id"])
        subject  = "Welcome to ItsOnMe"
        email    = data["email"]
        name     = "#{data['name']} Staff"
        body     = text_for_merchant_signup_welcome(data)
        puts body.inspect
        bcc      = bcc_company_email

        puts "\n Emailer #{body.inspect}"

        template_name = "merchant"
        message       = message_hash(subject, email, name, body, bcc)
        request_mandrill_with_template(template_name, message, [data['id'], "Merchant"])
    end

    def merchant_pending data
        merchant = Merchant.unscoped.find(data["merchant_id"])
        subject  = "Your ItsOnMe account is pending approval"
        email    = data["email"]
        name     = "#{merchant.name} Staff"
        body     = text_for_merchant_pending(merchant)
        bcc      = bcc_company_email

        template_name = "merchant"
        message       = message_hash(subject, email, name, body, bcc)
        request_mandrill_with_template(template_name, message, [merchant.id, "Merchant"])
    end

    def merchant_approved data
        merchant = Merchant.unscoped.find(data["merchant_id"])
        subject  = "You have been Approved!"
        email    = data["email"]
        name     = "#{merchant.name} Staff"
        body     = text_for_merchant_approved(merchant)
        bcc      = bcc_company_email

        template_name = "merchant"
        message       = message_hash(subject, email, name, body, bcc)
        request_mandrill_with_template(template_name, message, [merchant.id, "Merchant"])
    end

    def merchant_live data
        merchant = Merchant.unscoped.find(data["merchant_id"])
        subject  = "Your location is now live"
        email    = data["email"]
        name     = "#{merchant.name} Staff"
        body     = text_for_merchant_live(merchant)
        bcc      = bcc_company_email

        template_name    = "merchant"
        message       = message_hash(subject, email, name, body, bcc)
        request_mandrill_with_template(template_name, message, [merchant.id, "Merchant"])
    end

private

    def request_mandrill_with_template(template_name, message, ditto_ary, template_content=nil)
        if Rails.env.staging? || Rails.env.production?
            # unless Rails.env.development?
            puts "``````````````````````````````````````````````"
            add_qa_text_to_subject(message)
            puts "Emailer[286] - Request Mandrill with TemplateName: '#{template_name}' \nMessage:\n#{message} \nContent:\n#{template_content}"
            m = MANDRILL_CLIENT
            response = m.messages.send_template(template_name, template_content, message)
            puts "Response from Mandrill #{response.inspect}"
            puts "``````````````````````````````````````````````"
            Ditto.send_email_create(response, ditto_ary[0], ditto_ary[1])
            response
        end
    end

    def request_mandrill_with_message message, ditto_ary
        if Rails.env.staging? || Rails.env.production?
            puts "``````````````````````````````````````````````"
            puts " Emailer[298] - Request Mandrill with #{message}"
            add_qa_text_to_subject(message)
            m = MANDRILL_CLIENT
            response = m.messages.send message
            puts
            puts "Here is the Mandrill response = #{response.first}"
            puts "``````````````````````````````````````````````"
            Ditto.send_email_create(response, ditto_ary[0], ditto_ary[1])
            return response
        end
    end

    def whitelist_email(email)
        # if email is on blacklist then send email to noreplydrinkboard@gmail.com
        # blacklist is
        bad_emails = ["test@test.com", "jp@jp.com", "jb@jb.com", "gj@gj.com", "fl@fl.com", "adam@adam.com", "rs@rs.com","kk@gmail.com", "bitmover1@gmail.com", "app@gmail.com", "spnoge@bob.com", "adam@gmail.com", "gifter@sos.me", "taylor@gmail.com"]
        email = "noreplydrinkboard@gmail.com" if bad_emails.include?(email)

        return email
    end

    def blank_merge_var(str)
        if str.blank?
            "&nbsp;".html_safe
            nil
        else
            str
        end
    end

    def expired_merge_var(datetime_string)
        if datetime_string.blank?
            "&nbsp;".html_safe
        else
            "<div style='font-size:15px; color:#8E8D8D;'>Gift Expires: #{make_date_s(datetime_string)}</div>".html_safe
        end
    end

    def message_hash(subject, email, name, body, bcc=nil, provider_name=nil)
        email = whitelist_email(email)
        message          = {
            "subject"     => subject,
            "from_name"   => "ItsOnMe",
            "from_email"  => NO_REPLY_EMAIL,
            "to"          => [
                { "email" => email, "name" => name }
            ],
            "global_merge_vars" => [
                { "name" => "body", "content" => body }
            ]
        }
        if bcc.present?
            message["to"] << { "email" => bcc, "name" => bcc, "type" => "bcc" }
        end
        if provider_name.present?
            message["tags"] = [provider_name]
        end
        message
    end

    def bcc_company_email
        HELP_CONTACT[0]
    end

    def whitelist_user(user)
        # if user.email is on blacklist then send email to noreplydrinkboard@gmail.com
        return whitelist_email(user.email)
    end

    def add_qa_text_to_subject message
        unless Rails.env.production?
            message["subject"].insert(0, "QA - ")
        end
    end

end

    # def subject template_name, options=nil
    #     case template_name
    #     when "iom-gift-unopened-giver"
    #         "#{options[:receiver_name]} hasn't opened your gift"
    #     when "iom-gift-unopened-receiver"
    #         "You have gifts waiting for you!"
    #     when "iom-boomerang-notice-2"
    #         "Boomerang! We're returning this gift to you."
    #     end
    # end

    ##### OLD EMAILERS

    # def reminder_gift_giver recipient, receiver_name
    #     ###----> remind giver to remind recipient, after one month , cron job
    #     template_name    = "iom-gift-unopened-giver"
    #     user_name        = recipient.name #user/purchaser receiving the email
    #     template_content = [{"name" => "user_name", "content" => user_name},
    #                         {"name" => "receiver_name", "content" => receiver_name},
    #                         {"name" => "service_name", "content" => SERVICE_NAME}]
    #     email            = recipient.email
    #     name             = recipient.name
    #     link             = nil
    #     bcc              = nil # add email if necessary. Currently, info@db.com is the only automatic default cc.
    #     message          = message_hash_old(subject(template_name, options = {receiver_name: receiver_name}), email, name, link, bcc)
    #     request_mandrill_with_template(template_name, message, [recipient.id, "User"], template_content)
    # end


