module Emailer

    def send_gift_notice recipient, giver_name, merchant_name, gift
		template_name    = "gift-notice"
		recipient_name   = recipient.name
		giver_name       = #person that sent the gift
		merchant_name    =
		gift_details     = # example string: "<ul><li>1 Budweiser</li><li>1 Shot Patron</li></ul>"
		gift_total       = #monetary value. do not include dollar sign
		template_content = [{"name" => "receiver_name", "content" => recipient_name},
							{"name" => "giver_name", "content" => giver_name},
							{"name" => "merchant_name", "content" => merchant_name},
							{"name" => "gift_details", "content" => gift_details},
							{"name" => "gift_total", "content" => gift_total}]
		subject          = "#{giver_name} sent you a gift on Drinkboard"
		email            = recipient.email
		name             = recipient.name
		link             = #link to gift
        bcc              = nil # add email if necessary. Currently, info@db.com is the only automatic default cc.
		message          = message_hash(subject, email, name, link, bcc)
		request_mandrill_with_template(template_name, template_content, message)
    end

    def send_purchase_receipt recipient, receiver_name, merchant_name, gift
		template_name    = "purchase-receipt"
		user_name        = recipient.name #user/purchaser receiving the email
		receiver_name    = #person to whom the gift was sent
		merchant_name    =
		gift_details     = # example string: "<ul><li>1 Budweiser</li><li>1 Shot Patron</li></ul>"
		gift_total       = #monetary value. do not include dollar sign
        processing_fee   = #monetary value. do not include dollar sign
        grand_total      = #monetary value. do not include dollar sign
		template_content = [{"name" => "user_name", "content" => user_name},
							{"name" => "receiver_name", "content" => receiver_name},
							{"name" => "merchant_name", "content" => merchant_name},
							{"name" => "gift_details", "content" => gift_details},
							{"name" => "gift_total", "content" => gift_total},
							{"name" => "processing_fee", "content" => processing_fee},
							{"name" => "grand_total", "content" => grand_total}]
		subject          = "Your purchase is complete"
		email            = recipient.email
		name             = recipient.name
		link             = nil
        bcc              = nil # add email if necessary. Currently, info@db.com is the only automatic default cc.
		message          = message_hash(subject, email, name, link, bcc)
		request_mandrill_with_template(template_name, template_content, message)
    end

    def send_recipient_gift_unopened recipient, receiver_name
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

	def generate_invite_link invite_token
		"#{MT_URL}invite?token=#{invite_token}"
	end

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
