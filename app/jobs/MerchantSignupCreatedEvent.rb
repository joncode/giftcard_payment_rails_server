class MerchantSignupCreatedEvent

    @queue = :database

	def self.perform ms_id
		puts "MerchantSignupCreatedEvent START #{ms_id}"
		ms = MerchantSignup.find(ms_id)

		# notify internal that sign up has been created
		Alert.perform("MERCHANT_SUBMITTED_SYS", ms)

		merchant = nil
		license = nil
		if ms.promotable?
			# promote merchant to live
			merchant = ms.promote

			if merchant && merchant.save
				# handles the merchant set up criteria
					# quick gifts
					# make MT users
					# make widget clients
					# make default vouchers
				ms.update(merchant_id: merchant.id)
				if ms.term == 'Year'
					license = License.annual_basic(merchant)
				elsif ms.term == "Month"
					license = License.monthly_basic(merchant)
				else
					# term does not have correct response
					OpsTwilio.text_dev msg: "#{ms.id} failed to TERM license"
				end
			else
				OpsTwilio.text_dev msg: "#{ms.id} failed to make merchant #{merchant.errors}"
			end
		end

		# exchange stripe token for customer account
		# save CC in DB
		card = ms.create_card

		if card.stripe_user_id && license
			# set up the subscription in stripe ?
			res = OpsStripeToken.create_subscription(card.stripe_user_id, license.stripe_plan_id)

			puts res.inspect

			# attach card to merchant ?
			license.update(charge_type: 'card', charge_id: card.id)
		end

		# send welcome email to merchants
        e = EmailWelcome.new(merchant || ms)
	    e.send_email
	    		# old way
			        # data = { 'text' => 'merchant_signup_welcome', 'args' => ms }
			        # MailerJob.perform(data)
	end


end