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
		body             = text_for_user_reset_password(user)
		template_name    = "user"
		template_content = [{ "name" => "body", "content" => body }]
		message          = {
			"subject"     => "Reset password request",
			"from_name"   => "It's On Me",
			"from_email"  => "no-reply@itson.me",
			"to"          => [{ "email" => user.email, "name" => user.name }],
			"merge_vars"  => [{
				"rcpt" => user.email,
				"vars" => template_content
			}]
		}
		add_qa_text_to_subject(message)
		request_mandrill_with_template(template_name, template_content, message, [data["user_id"], user.class.name])
	end

	def confirm_email data
		user		     = User.find(data["user_id"])
		link             = data["link"]
		template_name    = "user"
		template_content = [{ "name" => "body", "content" => text_for_user_confirm_email(user, link) }]
		message          = {
			"subject" => "Confirm you email address",
			"from_name"   => "It's On Me",
			"from_email"  => "no-reply@itson.me",
			"to" => [{
				"email" => user.email,
				"name" => user.name
			}],
			"bcc_address" => "info@itson.me",
			"merge_vars" => [{
				"rcpt" => user.email,
				"vars" => template_content
			}]
		}
		request_mandrill_with_template(template_name, template_content, message, [data["user_id"], "User"])
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
    	gift 			 = Gift.find(data["gift_id"])
		template_name    = "gift"
		receiver_name   = gift.receiver_name
		giver_name       = gift.giver_name
		if gift.receiver_email
			email         = gift.receiver_email
		elsif gift.receiver
			email 		  = gift.receiver.email
		else
			puts "NOTIFY RECEIVER CALLED WITHOUT RECEIVER EMAIL"
			return nil
		end
		template_content = [{ "name" => "body", "content" => text_for_gift_sale(gift) }]
		message          = {
			"subject" => "#{giver_name} sent you a gift",
			"from_name"   => "It's On Me",
			"from_email"  => "no-reply@itson.me",
			"to" => [{
				"email" => email,
				"name" => receiver_name
			}],
			"merge_vars" => [{
				"rcpt" => email,
				"vars" => template_content
			}]
		}
		request_mandrill_with_template(template_name, template_content, message, [data["gift_id"], "Gift"])
    end

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
		message          = message_hash(subject(template_name), email, recipient_name, link, bcc)
		request_mandrill_with_template(template_name, template_content, message, [data["gift_id"], "Gift"])
    end

    def notify_receiver_proto_join data
    	gift = Gift.find(data["gift_id"])
		template_name = "gift"
		receiver_name = gift.receiver_name
		merchant_name = gift.provider_name
		if gift.receiver_email
			email     = whitelist_email(gift.receiver_email)
		elsif gift.receiver
			email 	  = whitelist_email(gift.receiver.email)
		else
			puts "NOTIFY RECEIVER CALLED WITHOUT RECEIVER EMAIL"
			return nil
		end
		template_content = [{ "name" => "body", "content" => text_for_gift_proto(gift) }]
		message          = {
			"subject" => "The staff at #{merchant_name} sent you a gift",
			"from_name"   => "It's On Me",
			"from_email"  => "no-reply@itson.me",
			"to" => [{
				"email" => email,
				"name" => receiver_name
			}],
			"merge_vars" => [{
				"rcpt" => email,
				"vars" => template_content
			}],
			"tags" => [ merchant_name ]
		}
		request_mandrill_with_template(template_name, template_content, message, [data["gift_id"], "Gift"])
    end

    def invoice_giver data
    	gift 			 = Gift.find(data["gift_id"])
		email            = gift.giver.email
		name             = gift.giver_name
		template_name    = "user"
		template_content = [{ "name" => "body", "content" => text_for_user_receipt(gift) }]
		message          = {
			"subject" => "Gift purchase receipt",
			"from_name"   => "It's On Me",
			"from_email"  => "no-reply@itson.me",
			"to" => [{
				"email" => email,
				"name" => name
			}],
			"merge_vars" => [{
				"rcpt" => email,
				"vars" => template_content
			}]
		}
		request_mandrill_with_template(template_name, template_content, message, [data["gift_id"], "Gift"])
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
		message          = message_hash(subject(template_name), email, name, link, bcc)
		request_mandrill_with_template(template_name, template_content, message, [recipient.id, "User"])
    end

##### Merchant Tools

	def merchant_invite data
		email            = data["email"]
		merchant         = Merchant.find(data["merchant_id"])
		token            = data["token"]

		body             = text_for_merchant_invite(merchant, token)
		template_name    = "merchant"
		template_content = [{ "name" => "body", "content" => body }]
		message          = {
			"subject"     => "Welcome to It's On Me",
			"from_name"   => "It's On Me",
			"from_email"  => "no-reply@itson.me",
			"to"          => [{ "email" => email, "name" => "#{merchant.name} Staff" }],
			"bcc_address" => "rachel.wenman@itson.me",
			"merge_vars"  => [{
				"rcpt" => email,
				"vars" => template_content
			}]
		}
		add_qa_text_to_subject(message)
		request_mandrill_with_template(template_name, template_content, message, [merchant.id, "Merchant"])
	end

	def merchant_staff_invite data
		email = data["email"]
		invitor_name = data["invitor_name"]
		merchant = Merchant.find(data["merchant_id"])
		invite_token = data["token"]
		body             = text_for_merchant_staff_invite(merchant, invitor_name, invite_token)
		template_name    = "merchant"
		template_content = [{ "name" => "body", "content" => body }]
		message          = {
			"subject"     => "Welcome to It's On Me",
			"from_name"   => "It's On Me",
			"from_email"  => "no-reply@itson.me",
			"to"          => [{ "email" => email, "name" => "#{ merchant.name } Staff" }],
			"bcc_address" => "rachel.wenman@itson.me",
			"merge_vars"  => [{
				"rcpt" => email,
				"vars" => template_content
			}]
		}
		add_qa_text_to_subject(message)
		request_mandrill_with_template(template_name, template_content, message, [merchant.id, "Merchant"])
	end

	def merchant_pending data
		email            = data["email"]
		merchant         = Merchant.find(data["merchant_id"])
		body             = text_for_merchant_pending(merchant)
		template_name    = "merchant"
		template_content = [{ "name" => "body", "content" => body }]
		message          = {
			"subject"     => "Your It's On Me account is pending approval",
			"from_name"   => "It's On Me",
			"from_email"  => "no-reply@itson.me",
			"to"          => [{ "email" => email, "name" => "#{merchant.name} Staff" }],
			"bcc_address" => "rachel.wenman@itson.me",
			"merge_vars"  => [{
				"rcpt" => email,
				"vars" => template_content
			}]
		}
		add_qa_text_to_subject(message)
		request_mandrill_with_template(template_name, template_content, message, [merchant.id, "Merchant"])
	end

	def merchant_approved data
		email            = data["email"]
		merchant         = Merchant.find(data["merchant_id"])
		body             = text_for_merchant_approved(merchant)
		template_name    = "merchant"
		template_content = [{ "name" => "body", "content" => body }]
		message          = {
			"subject"     => "You have been Approved!",
			"from_name"   => "It's On Me",
			"from_email"  => "no-reply@itson.me",
			"to"          => [{ "email" => email, "name" => "#{merchant.name} Staff" }],
			"bcc_address" => "rachel.wenman@itson.me",
			"merge_vars"  => [{
				"rcpt" => email,
				"vars" => template_content
			}]
		}
		add_qa_text_to_subject(message)
		request_mandrill_with_template(template_name, template_content, message, [merchant.id, "Merchant"])
	end

	def merchant_live data
		email            = data["email"]
		merchant         = Merchant.find(data["merchant_id"])
		body             = text_for_merchant_live(merchant)
		template_name    = "merchant"
		template_content = [{ "name" => "body", "content" => body }]
		message          = {
			"subject"     => "Your location is now live",
			"from_name"   => "It's On Me",
			"from_email"  => "no-reply@itson.me",
			"to"          => [{ "email" => email, "name" => "#{merchant.name} Staff" }],
			"bcc_address" => "rachel.wenman@itson.me",
			"merge_vars"  => [{
				"rcpt" => email,
				"vars" => template_content
			}]
		}
		add_qa_text_to_subject(message)
		request_mandrill_with_template(template_name, template_content, message, [merchant.id, "Merchant"])
	end

private

	def subject template_name, options=nil
		subject_content =
			case template_name
			when "iom-confirm-email";          then "Confirm Your Email"
			when "iom-gift-hasnt-gifted";      then "ItsOnMe Is Ready to Fulfill Your Mobile Gifting Needs!"
			when "iom-gift-notify-receiver";   then "#{options[:giver_name]} sent you a gift on ItsOnMe"
			when "iom-gift-receipt";           then "Your gift purchase is complete"
			when "iom-gift-unopened-giver";    then "#{options[:receiver_name]} hasn't opened your gift"
			when "iom-gift-unopened-receiver"; then "You have gifts waiting for you!"
			when "iom-reset-password";         then "Reset Your Password"
			when "iom-user-welcome";           then "Welcome to ItsOnMe!"
			when "iom-boomerang-notice";       then "Boomerang! We're returning this gift to you."
			when "iom-boomerang-notice-2";       then "Boomerang! We're returning this gift to you."
			end
		if Rails.env.development? || Rails.env.staging?
			subject_content = subject_content.insert(0, "QA- ")
		end
		subject_content
	end

	def message_hash(subject, email, name, link=nil, bcc=nil)
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

	def request_mandrill_with_template(template_name, template_content, message, ditto_ary)
		unless Rails.env.development?
			puts "``````````````````````````````````````````````"
			puts "Request Mandrill with #{template_name} #{message}"
			require 'mandrill'
			m = Mandrill::API.new(MANDRILL_APIKEY)
			response = m.messages.send_template(template_name, template_content, message)

			puts
			puts "Response from Mandrill #{response.inspect}"
			puts "``````````````````````````````````````````````"
			Ditto.send_email_create(response, ditto_ary[0], ditto_ary[1])
			response
		end
	end

    def request_mandrill_with_message message, ditto_ary
        puts "``````````````````````````````````````````````"
        puts "Request Mandrill with #{message}"
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
