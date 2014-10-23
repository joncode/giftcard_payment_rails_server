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
		body     = text_for_user_reset_password(user)

		template_name = "user"
		message       = message_hash(subject, user.email, user.name, body)
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
    	gift          = Gift.find(data["gift_id"])
		receiver_name = gift.receiver_name
		giver_name    = gift.giver_name
		if gift.receiver_email
			email     = gift.receiver_email
		elsif gift.receiver
			email     = gift.receiver.email
		else
			puts "NOTIFY RECEIVER CALLED WITHOUT RECEIVER EMAIL"
			return nil
		end
		subject       = "#{giver_name} sent you a gift"
		body          = text_for_notify_receiver(gift)

		template_name = "gift"
		message       = message_hash(subject, email, receiver_name, body, nil, gift.provider_name)
		request_mandrill_with_template(template_name, message, [data["gift_id"], "Gift"])
    end

    def notify_receiver_proto_join data
    	gift          = Gift.find(data["gift_id"])
		receiver_name = gift.receiver_name
		merchant_name = gift.provider_name
		giver_name    = gift.giver_name ? gift.giver_name : merchant_name
		if gift.receiver_email
			email     = whitelist_email(gift.receiver_email)
		elsif gift.receiver
			email 	  = whitelist_email(gift.receiver.email)
		elsek
			puts "NOTIFY RECEIVER CALLED WITHOUT RECEIVER EMAIL"
			return nil
		end
		subject  = "The staff at #{giver_name} sent you a gift"
		body     = text_for_notify_receiver_proto_join(gift)

		template_name   = "gift"
		message         = message_hash(subject, email, receiver_name, body)
		message["tags"] = [ merchant_name ]
		request_mandrill_with_template(template_name, message, [data["gift_id"], "Gift"])
    end

    def invoice_giver data
    	gift    = Gift.find(data["gift_id"])
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

	def merchant_invite data
		merchant = Merchant.find(data["merchant_id"])
		subject  = "Welcome to It's On Me"
		email    = data["email"]
		name     = "#{merchant.name} Staff"
		body     = text_for_merchant_invite(merchant, data["token"])
		bcc      = bcc_company_email

		template_name = "merchant"
		message       = message_hash(subject, email, name, body, bcc)
		request_mandrill_with_template(template_name, message, [merchant.id, "Merchant"])
	end

	def merchant_staff_invite data
		merchant     = Merchant.find(data["merchant_id"])
		invitor_name = data["invitor_name"]
		invite_token = data["token"]
		subject      = "Welcome to It's On Me"
		email        = data["email"]
		name         = "#{merchant.name} Staff"
		body         = text_for_merchant_staff_invite(merchant, invitor_name, invite_token)
		bcc          = bcc_company_email

		template_name = "merchant"
		message       = message_hash(subject, email, name, body, bcc)
		request_mandrill_with_template(template_name, message, [merchant.id, "Merchant"])
	end

	def merchant_pending data
		merchant = Merchant.find(data["merchant_id"])
		subject  = "Your It's On Me account is pending approval"
		email    = data["email"]
		name     = "#{merchant.name} Staff"
		body     = text_for_merchant_pending(merchant)
		bcc      = bcc_company_email

		template_name = "merchant"
		message       = message_hash(subject, email, name, body, bcc)
		request_mandrill_with_template(template_name, message, [merchant.id, "Merchant"])
	end

	def merchant_approved data
		merchant = Merchant.find(data["merchant_id"])
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
		merchant = Merchant.find(data["merchant_id"])
		subject  = "Your location is now live"
		email    = data["email"]
		name     = "#{merchant.name} Staff"
		body     = text_for_merchant_live(merchant)
		bcc      = bcc_company_email

		template_name    = "merchant"
		message       = message_hash(subject, email, name, body, bcc)
		request_mandrill_with_template(template_name, message, [merchant.id, "Merchant"])
	end

##### OLD EMAILERS

    def notify_receiver_boomerang data
    	gift 			  = GiftBoomerang.find(data["gift_id"])
		original_receiver = gift.original_receiver_social

		template_name    = "iom-boomerang-notice-2"
		recipient_name   = gift.receiver_name
		if gift.receiver_email
			email         = gift.receiver_email
		elsif gift.receiver
			email 		  = gift.receiver.email
		else
			puts "NOTIFY RECEIVER BOOMERANG CALLED WITHOUT RECEIVER EMAIL"
			return nil
		end

    	items_text       = items_text(gift)
		adjusted_id 	 = NUMBER_ID + gift.id
		link             = "#{PUBLIC_URL}/signup/acceptgift?id=#{adjusted_id}"
        bcc              = "info@itson.me"
        template_content = [
        	{ "name" => "items_text", "content" => items_text },
        	{ "name" => "original_receiver", "content" => original_receiver}]
		message          = message_hash_old(subject(template_name), email, recipient_name, link, bcc)
		request_mandrill_with_template(template_name, message, [data["gift_id"], "Gift"], template_content)
    end

	def reminder_gift_giver recipient, receiver_name
    	###----> remind giver to remind recipient, after one month , cron job
		template_name    = "iom-gift-unopened-giver"
		user_name        = recipient.name #user/purchaser receiving the email
		template_content = [{"name" => "user_name", "content" => user_name},
							          {"name" => "receiver_name", "content" => receiver_name},
		                    {"name" => "service_name", "content" => SERVICE_NAME}]
		email            = recipient.email
		name             = recipient.name
		link             = nil
        bcc              = nil # add email if necessary. Currently, info@db.com is the only automatic default cc.
		message          = message_hash_old(subject(template_name, options = {receiver_name: receiver_name}), email, name, link, bcc)
		request_mandrill_with_template(template_name, message, [recipient.id, "User"], template_content)
    end

    def reminder_gift_receiver data
    	###----> after a month , you have a gift you havent used , use it or re-gift it
    	recipient        = User.find(data["user_id"])
		template_name    = "iom-gift-unopened-receiver"
		user_name        = recipient.name #user/purchaser receiving the email
		template_content = [{"name" => "user_name", "content" => user_name},
		                    {"name" => "service_name", "content" => SERVICE_NAME}]
		email            = recipient.email
		name             = recipient.name
		link             = nil
        bcc              = nil # add email if necessary. Currently, info@db.com is the only automatic default cc.
		message          = message_hash_old(subject(template_name), email, name, link, bcc)
		request_mandrill_with_template(template_name, message, [recipient.id, "User"], template_content)
    end

private

	def request_mandrill_with_template(template_name, message, ditto_ary, template_content=nil)
		# unless Rails.env.development?
			puts "``````````````````````````````````````````````"
			add_qa_text_to_subject(message)
			puts "Request Mandrill with #{template_name} #{message}"
			require 'mandrill'
			m = Mandrill::API.new(MANDRILL_APIKEY)
			response = m.messages.send_template(template_name, template_content, message)
			puts "Response from Mandrill #{response.inspect}"
			puts "``````````````````````````````````````````````"
			Ditto.send_email_create(response, ditto_ary[0], ditto_ary[1])
			response
		# end
	end

    def request_mandrill_with_message message, ditto_ary
        puts "``````````````````````````````````````````````"
        puts "Request Mandrill with #{message}"
		add_qa_text_to_subject(message)
        require 'mandrill'
        m        = Mandrill::API.new(MANDRILL_APIKEY)
        response = m.messages.send message
        puts
        puts "Here is the Mandrill response = #{response.first}"
        puts "``````````````````````````````````````````````"
        Ditto.send_email_create(response, ditto_ary[0], ditto_ary[1])
        return response
    end

	def whitelist_email(email)
					# if email is on blacklist then send email to noreplydrinkboard@gmail.com
					# blacklist is
		bad_emails = ["test@test.com", "jp@jp.com", "jb@jb.com", "gj@gj.com", "fl@fl.com", "adam@adam.com", "rs@rs.com","kk@gmail.com", "bitmover1@gmail.com", "app@gmail.com", "spnoge@bob.com", "adam@gmail.com", "gifter@sos.me", "taylor@gmail.com"]
		if bad_emails.include?(email)
				email = "noreplydrinkboard@gmail.com"
		end

		return email
	end

	def message_hash(subject, email, name, body, bcc=nil, provider_name=nil)
		email = whitelist_email(email)
		message          = {
			"subject"     => subject,
			"from_name"   => "It's On Me",
			"from_email"  => "no-reply@itson.me",
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
		if Rails.env.production?
			"rachel.wenman@itson.me"
		else
			nil
		end
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

	def subject template_name, options=nil
		case template_name
		when "iom-gift-unopened-giver"
			"#{options[:receiver_name]} hasn't opened your gift"
		when "iom-gift-unopened-receiver"
			"You have gifts waiting for you!"
		when "iom-boomerang-notice-2"
			"Boomerang! We're returning this gift to you."
		end
	end

	def message_hash_old(subject, email, name, link=nil, bcc=nil)
		email = whitelist_email(email)
		message = {
			"subject"     => subject,
			"from_name"   => "#{SERVICE_NAME}",
			"from_email"  => "#{NO_REPLY_EMAIL}",
			"to"          => [{ "email" => email, "name" => name }],
			"bcc_address" => bcc,
			"merge_vars"  =>[
				{
					"rcpt" => email,
					"vars" => [{"name" => "link", "content" => link}]
				}
			]
		}
		message
	end

end
