module Emailer

	def reset_password data
		recipient		 = data["user"]
		email            = recipient.email
		name             = recipient.name
		template_name    = "reset-password"
		template_content = [{"name" => "recipient_name", "content" => name}]

		subject          = "Reset Your Password"

		link             = "#{PUBLIC_URL}/account/reset_password/#{recipient.reset_token}"

		message          = message_hash(subject, email, name, link)
		request_mandrill_with_template(template_name, template_content, message)
	end

    def notify_receiver data
    	gift 			 = data["gift"]
		template_name    = "gift-notice"
		recipient_name   = gift.receiver_name
		giver_name       = gift.giver_name
		merchant_name    = gift.provider_name
		email            = gift.receiver_email
		gift_details     = GiftItem.items_for_email(gift)	# example string: "<ul><li>1 Budweiser</li><li>1 Shot Patron</li></ul>"
		gift_total       = gift.total 						# monetary value. do not include dollar sign
		template_content = [{"name" => "receiver_name", "content" => recipient_name},
							{"name" => "giver_name", "content" => giver_name},
							{"name" => "merchant_name", "content" => merchant_name},
							{"name" => "gift_details", "content" => gift_details},
							{"name" => "gift_total", "content" => gift_total}]
		subject          = "#{giver_name} sent you a gift on Drinkboard"
		link             = nil	#link to gift
        bcc              = nil 	# add email if necessary. Currently, info@db.com is the only automatic default cc.
		message          = message_hash(subject, email, recipient_name, link, bcc)
		request_mandrill_with_template(template_name, template_content, message)
    end

    def invoice_giver data
    	gift 			 = data["gift"]
		template_name    = "purchase-receipt"
		user_name        = gift.giver_name 		#user/purchaser receiving the email
		receiver_name    = gift.receiver_name	#person to whom the gift was sent
		merchant_name    = gift.provider_name
		gift_details     = GiftItem.items_for_email(gift)	# example string: "<ul><li>1 Budweiser</li><li>1 Shot Patron</li></ul>"
		gift_total       = gift.total   		#monetary value. do not include dollar sign
        processing_fee   = gift.service 		#monetary value. do not include dollar sign
        grand_total      = gift.grand_total 	#monetary value. do not include dollar sign
		template_content = [{"name" => "user_name", "content" => user_name},
							{"name" => "receiver_name", "content" => receiver_name},
							{"name" => "merchant_name", "content" => merchant_name},
							{"name" => "gift_details", "content" => gift_details},
							{"name" => "gift_total", "content" => gift_total},
							{"name" => "processing_fee", "content" => processing_fee},
							{"name" => "grand_total", "content" => grand_total}]
		subject          = "Your purchase is complete"
		email            = gift.giver_email
		name             = gift.giver_name
		link             = nil
        bcc              = nil # add email if necessary. Currently, info@db.com is the only automatic default cc.
		message          = message_hash(subject, email, name, link, bcc)
		request_mandrill_with_template(template_name, template_content, message)
    end

    def send_recipient_gift_unopened recipient, receiver_name
    	###----> remind giver to remind recipient, after one month , cron job
		template_name    = "recipient-gift-unopened"
		user_name        = recipient.name #user/purchaser receiving the email
		receiver_name    = #person to whom the gift was sent
		template_content = [{"name" => "user_name", "content" => user_name},
							{"name" => "receiver_name", "content" => receiver_name}]
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
		template_name    = "reminder-hasnt-gifted"
		user_name        = recipient.name #user/purchaser receiving the email
		template_content = [{"name" => "user_name", "content" => user_name}]
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
		template_name    = "reminder-unused-gift"
		user_name        = recipient.name #user/purchaser receiving the email
		template_content = [{"name" => "user_name", "content" => user_name}]
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
		message = {
			"subject"     => subject,
			"from_name"   => "Drinkboard",
			"from_email"  => 'no-reply@drinkboard.com',
			"to"          => [{"email" => email, "name" => name},
				              {"email" => "info@drinkboard.com", "name" => ""}],
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

	# def generate_invite_link invite_token
	# 	"#{MT_URL}invite?token=#{invite_token}"
	# end

	def request_mandrill_with_template(template_name, template_content, message)
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
