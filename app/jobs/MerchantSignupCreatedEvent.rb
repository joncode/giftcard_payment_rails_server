class MerchantSignupCreatedEvent

    @queue = :database

	def self.perform ms_id
		puts "MerchantSignupCreatedEvent START #{ms_id}"
		ms = MerchantSignup.find(ms_id)

		if ms.promotable?
			# promote merchant to live
			merchant = ms.promote

			merchant.save
			# handles the merchant set up criteria
				# quick gifts
				# make MT users
				# make widget clients
				# make default vouchers
		end

		# exchange stripe token for customer account
		# save CC in DB
		card = ms.create_card

		# attach card to merchant ?
		# set up the subscription in stripe ?

		# notify internal that sign up has been created
		Alert.perform("MERCHANT_SUBMITTED_SYS", ms)

		# send welcome email to merchants
        data = { 'text' => 'merchant_signup_welcome', 'args' => ms }
        MailerJob.perform(data)

	end


end