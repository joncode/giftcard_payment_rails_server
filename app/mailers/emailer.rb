module Emailer
	include EmailHelper

	# uncomment info@db.com from message in Emailer

	def reset_password data
		recipient		 = User.find(data["user_id"])
		email            = recipient.email
		name             = recipient.name
		template_name    = "iom-reset-password"
		template_content = [{"name" => "recipient_name", "content" => name},
		                    {"name" => "service_name", "content" => SERVICE_NAME}]
		link             = "#{PUBLIC_URL}/account/resetpassword/#{recipient.reset_token}"

		message          = message_hash(subject(template_name), email, name, link)
		request_mandrill_with_template(template_name, template_content, message, [data["user_id"], "User"])
	end

	def confirm_email data
		recipient		 = User.find(data["user_id"])
		link             = data["link"]
		template_name    = "iom-confirm-email"
		template_content = [{"name" => "recipient_name", "content" => recipient.name},
		                    {"name" => "service_name", "content" => SERVICE_NAME}]
        bcc              = "info@itson.me"
		message          = message_hash(subject(template_name), recipient.email, recipient.name, link, bcc)
		request_mandrill_with_template(template_name, template_content, message, [data["user_id"], "User"])
	end

	def welcome data
		user      = User.find(data["user_id"])
		email     = user.email
		user_name = user.name

		template_name    = "iom-user-welcome"
		template_content = [{"name" => "user_name", "content" => user_name}]
        bcc              = "info@itson.me"
		message          = message_hash(subject(template_name), email, user_name, nil, bcc)
		request_mandrill_with_template(template_name, template_content, message, [data["user_id"], "User"])
	end

    def notify_receiver data
    	gift 			 = Gift.find(data["gift_id"])
		template_name    = "iom-gift-notify-receiver"
		recipient_name   = gift.receiver_name
		giver_name       = gift.giver_name
		if gift.receiver_email
			email         = gift.receiver_email
		elsif gift.receiver
			email 		  = gift.receiver.email
		else
			puts "NOTIFY RECEIVER CALLED WITHOUT RECEIVER EMAIL"
			return nil
		end
		adjusted_id 	 = NUMBER_ID + gift.id
		link             = "#{PUBLIC_URL}/signup/acceptgift?id=#{adjusted_id}"
        bcc              = nil 	# add email if necessary. Currently, info@db.com is the only automatic default cc.
        template_content = generate_template_content(gift, template_name)
		message          = message_hash(subject(template_name, options = {giver_name: giver_name}), email, recipient_name, link, bcc)
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
		template_name = "v2-0"
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
		template_content = [
			{ "name" => "merchant_name", "content" => merchant_name },
			{ "name" => "body", "content" => text_for_gift_proto(gift) }
		]
		message = {
			"subject" => "The staff at #{merchant_name} sent you a gift",
			"to" => [{
				"email" => email,
				"name" => receiver_name
			}],
			"merge_vars" => [{
				"rcpt" => email,
				"vars" => [
					{ "name" => "merchant_name", "content" => merchant_name },
					{ "name" => "body", "content" => text_for_gift_proto(gift) }
				]
			}],
			"tags" => [ merchant_name ]
		}
		request_mandrill_with_template(template_name, template_content, message, [data["gift_id"], "Gift"])
    end

    def invoice_giver data
    	gift 			 = Gift.find(data["gift_id"])
		template_name    = "iom-gift-receipt"
		email            = gift.giver.email
		name             = gift.giver_name
		link             = nil
        bcc              = "info@itson.me"
		template_content = generate_template_content(gift, template_name)
		message          = message_hash(subject(template_name), email, name, link, bcc)
		request_mandrill_with_template(template_name, template_content, message, [data["gift_id"], "Gift"])
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
		message          = message_hash(subject(template_name, options = {receiver_name: receiver_name}), email, name, link, bcc)
		request_mandrill_with_template(template_name, template_content, message, [recipient.id, "User"])
    end

    def reminder_hasnt_gifted recipient
    	###----> after month , user hasnt gifted , send this via cron
		template_name    = "iom-gift-hasnt-gifted"
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

    def reminder_gift_receiver recipient
    	###----> after a month , you have a gift you havent used , use it or re-gift it
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
					"vars" => generate_links(link)
				}
			]
		}
		message
	end

	def generate_links(link)
		[{"name" => "link", "content" => link}]
	end

    def generate_template_content gift, template_name
    	recipient_name   = (gift.receiver_name == GENERIC_RECEIVER_NAME) ? "" : gift.receiver_name
    	giver_name       = gift.giver_name
    	merchant_name    = gift.provider_name
    	gift_details     = GiftItem.items_for_email(gift)
    	gift_total       = gift.total
		template_content = [{"name" => "receiver_name", "content" => "#{recipient_name}"},
							{"name" => "merchant_name", "content" => merchant_name},
							{"name" => "gift_details", "content" => gift_details},
							{"name" => "gift_total", "content" => gift_total},
							{"name" => "service_name", "content" => SERVICE_NAME}]
		if template_name == "iom-gift-notify-receiver"
			template_content + [{"name" => "giver_name", "content" => giver_name}]
		elsif template_name == "iom-gift-receipt"
			template_content + [{"name" => "user_name", "content" => giver_name},
				                {"name" => "processing_fee", "content" => gift.service},
				                {"name" => "grand_total", "content" => gift.grand_total}]
		end
    end

	def request_mandrill_with_template(template_name, template_content, message, ditto_ary)
		unless Rails.env.development?
			puts "``````````````````````````````````````````````"
			puts "Request Mandrill with #{template_name} #{template_content}"
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

end
