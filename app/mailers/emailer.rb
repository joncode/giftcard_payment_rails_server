module Emailer

	# uncomment info@db.com from message in Emailer

	def reset_password data
		recipient		 = User.find(data["user_id"])
		email            = recipient.email
		name             = recipient.name
		template_name    = "iom-reset-password"
		template_content = [{"name" => "recipient_name", "content" => name},
		                    {"name" => "service_name", "content" => SERVICE_NAME}]
		subject          = "Reset Your Password"
		link             = "#{PUBLIC_URL}/account/resetpassword/#{recipient.reset_token}"

		message          = message_hash(subject, email, name, link)
		request_mandrill_with_template(template_name, template_content, message)
	end

	def confirm_email data
		recipient		 = User.find(data["user_id"])
		link             = data["link"]
		subject          = "Confirm Your Email"
		template_name    = "iom-confirm-email"
		template_content = [{"name" => "recipient_name", "content" => recipient.name},
		                    {"name" => "service_name", "content" => SERVICE_NAME}]
		message          = message_hash(subject, recipient.email, recipient.name, link)
		request_mandrill_with_template(template_name, template_content, message)
	end

    def notify_receiver data
    	gift 			 = Gift.find(data["gift_id"])
		template_name    = "iom-gift-notify-receiver"
		recipient_name   = gift.receiver_name
		giver_name       = gift.giver_name
		email            = gift.receiver_email
		subject          = "#{giver_name} sent you a gift on #{SERVICE_NAME}"
		adjusted_id 	 = NUMBER_ID + gift.id
		link             = "#{PUBLIC_URL}/signup/acceptgift/#{adjusted_id}"
        bcc              = nil 	# add email if necessary. Currently, info@db.com is the only automatic default cc.
        template_content = generate_template_content(gift, template_name)
		message          = message_hash(subject, email, recipient_name, link, bcc)
		request_mandrill_with_template(template_name, template_content, message)
    end

    def invoice_giver data
    	gift 			 = Gift.find(data["gift_id"])
		template_name    = "iom-gift-receipt"
		subject          = "Your gift purchase is complete"
		email            = gift.giver.email
		name             = gift.giver_name
		link             = nil
        bcc              = nil # add email if necessary. Currently, info@db.com is the only automatic default cc.
		template_content = generate_template_content(gift, template_name)
		message          = message_hash(subject, email, name, link, bcc)
		request_mandrill_with_template(template_name, template_content, message)
    end

    def send_recipient_gift_unopened recipient, receiver_name
    	###----> remind giver to remind recipient, after one month , cron job
		template_name    = "iom-gift-unopened-giver"
		user_name        = recipient.name #user/purchaser receiving the email
		receiver_name    = #person to whom the gift was sent
		template_content = [{"name" => "user_name", "content" => user_name},
							          {"name" => "receiver_name", "content" => receiver_name},
		                    {"name" => "service_name", "content" => SERVICE_NAME}]
		subject          = "#{receiver_name} hasn't opened your gift"
		email            = recipient.email
		name             = recipient.name
		link             = nil
        bcc              = nil # add email if necessary. Currently, info@db.com is the only automatic default cc.
		message          = message_hash(subject, email, name, link, bcc)
		request_mandrill_with_template(template_name, template_content, message)
    end

    def send_reminder_hasnt_gifted recipient
    	###----> after month , user hasnt gifted , send this via cron
		template_name    = "iom-gift-hasnt-gifted"
		user_name        = recipient.name #user/purchaser receiving the email
		template_content = [{"name" => "user_name", "content" => user_name},
		                    {"name" => "service_name", "content" => SERVICE_NAME}]
		subject          = "Ready to take that first step?"
		email            = recipient.email
		name             = recipient.name
		link             = nil
        bcc              = nil # add email if necessary. Currently, info@db.com is the only automatic default cc.
		message          = message_hash(subject, email, name, link, bcc)
		request_mandrill_with_template(template_name, template_content, message)
    end

    def send_reminder_unused_gift recipient
    	###----> after a month , you have a gift you havent used , use it or re-gift it
		template_name    = "iom-gift-unopened-receiver"
		user_name        = recipient.name #user/purchaser receiving the email
		template_content = [{"name" => "user_name", "content" => user_name},
		                    {"name" => "service_name", "content" => SERVICE_NAME}]
		subject          = "You have gifts waiting for you!"
		email            = recipient.email
		name             = recipient.name
		link             = nil
        bcc              = nil # add email if necessary. Currently, info@db.com is the only automatic default cc.
		message          = message_hash(subject, email, name, link, bcc)
		request_mandrill_with_template(template_name, template_content, message)
    end

private

	def message_hash(subject, email, name, link=nil, bcc=nil)
		email = whitelist_email(email)
		message = {
			"subject"     => subject,
			"from_name"   => "#{SERVICE_NAME}",
			"from_email"  => 'no-reply@itson.me',
			"to"          => [{"email" => email, "name" => name},
				             {"email" => "info@itson.me", "name" => ""}],
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
    	recipient_name   = gift.receiver_name
    	giver_name       = gift.giver_name
    	merchant_name    = gift.provider_name
    	gift_details     = GiftItem.items_for_email(gift)
    	gift_total       = gift.total
		template_content = [{"name" => "receiver_name", "content" => recipient_name},
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

	def request_mandrill_with_template(template_name, template_content, message)
		unless Rails.env.development?
			puts "``````````````````````````````````````````````"
			puts "Request Mandrill with #{template_name} #{template_content} #{message}"
			require 'mandrill'
			m = Mandrill::API.new
			response = m.messages.send_template(template_name, template_content, message)

			puts
			puts "Response from Mandrill #{response.inspect}"
			puts "``````````````````````````````````````````````"
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
