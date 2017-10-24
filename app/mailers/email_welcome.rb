class EmailWelcome < EmailAbstract
	# inherits from /app/mailers/email_abstract.rb

	def initialize merchant, subject="Welcome to the ItsOnMe Family!"
		super()
		if merchant.kind_of?(MerchantSignup)
			@merchant = merchant.merchant || merchant
		else
			@merchant = merchant
		end
		@template = "merchant-onboard-welcome-10-18-2017"
		@subject = subject
		@body = "<div></div>".html_safe
		if merchant.email.blank?
			puts "500 Internal - no email on #{merchant.id}"
			raise "Cannot Email for merchant #{merchant.id}"
		end
		@to_emails  = [{"email" => merchant.email, "name" => merchant.name }]
		set_bcc
		set_email_message_data
		set_vars
	end

	def set_vars
		h = { 	'support_phone' => TWILIO_QUICK_NUM,
				'widget_instruction_url' => @merchant.widget_instruction_url,
				'merchant_name' => @merchant.name,
				'merchant_address' => @merchant.address,
				'merchant_city_state_zip' => @merchant.city_state_zip,
				'merchant_phone' => number_to_phone(@merchant.phone)
			}
		set_vars_ary(h)
	end


end