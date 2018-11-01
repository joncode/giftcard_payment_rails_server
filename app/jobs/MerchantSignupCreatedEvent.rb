class MerchantSignupCreatedEvent

    @queue = :database

	def self.perform ms_id
		puts "MerchantSignupCreatedEvent START #{ms_id}"
		ms = MerchantSignup.find(ms_id)

		# notify internal that sign up has been created
		Alert.perform("MERCHANT_SUBMITTED_SYS", ms)

		# Notify GolfNow if this is a GolfNow signup
		##! There is a chance GolfNow signups will require payment in the future; this alert call will not happen if the course pays.
		#TODO: Check for an `affiliate_name` on the signup instead of using `payment_method`.  This requires Surfboard providing the data and Drinkboard storing it on the signup.  This would also allow better reporting, but I'm kind of totally buried, so it'll have to wait.
		payment_method = (ms['data']['payment_method']  rescue '')
		Alert.perform('GOLFNOW_MERCHANT_SUBMITTED_MT', ms)  if payment_method.strip.downcase == 'golfnow'

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

		if ms.data['payment_method'] == 'stripe'

			# exchange stripe token for customer account
			# save CC in DB
			card = ms.create_card

			if card && card.stripe_user_id && license
				# set up the subscription in stripe ?
				res = OpsStripeToken.create_subscription(card.stripe_user_id, license.stripe_plan_id)

				puts res.inspect

				# attach card to merchant ?
				license.update(charge_type: 'card', charge_id: card.id)
			end

		end

		# send welcome email to merchants
        e = EmailWelcome.new(merchant || ms)
	    e.send_email
	    		# old way
			        # data = { 'text' => 'merchant_signup_welcome', 'args' => ms }
			        # MailerJob.perform(data)
	end


end