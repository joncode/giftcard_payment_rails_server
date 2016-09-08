class Events::CallbacksController < MetalCorsController
	include MtSmsRedeem

	after_filter :set_content_type, only: :receive_sms

	def set_content_type
		self.content_type = "text/plain; charset=utf-8"
	end

	def receive_sms
		msg = params['Body']
		from_number = params['From']

		# msg = Message.create(params)

		dispatch_message(from_number, params, msg, from_number)

		@app_response = "You've reached ItsOnMe!  One of our people will be texting you shortly.  Thank you for your patience :)"
		respond
	end

	def zappernotify
		note = zapper_params
		note = note.stringify_keys
		r_id = note['Reference'].to_i
		r = Redemption.find r_id
		if r.update(status: 'redeemed')
			success 'ok'
		else
			# what to do here - zapper failed
		end
		respond
	end

# -----------   Twilio Service Methods

	def dispatch_message from, req, msg, from_number
		# if code = Message.merchant_redemption(msg)
		# 	redemption_msg from, code
		# elsif msg.downcase == 'support'
		# 	basic_support from
		# elsif ["+12152000475","+17029727139"].include?(from)
		# 	flip_phones from, msg
		# end
		OpsTwilio.text_devs msg: "TEXT-IN -> #{from_number} \n #{msg}"
	end

	def redemption_msg from, code
		mt_user = get_mt_user_with_number from
		if mt_user
			gift = find_gift_if_mt_user_has_notified_gifts(mt_user, code)
			if gift
				msg ="Gift #{code} is #{gift.value_s}"
			else
				msg ="No Gift was found for code = #{code}"
			end
		else
			msg ="No User was found for #{from}"
		end
		OpsTwilio.text to: from, msg: msg
	end

	def basic_support from
		mt_user = get_mt_user_with_number from
		if mt_user
			msg = "Text redemption code to see value of gift"
		else
			msg =  "This is ItsOnMe Support , how may we assist you?"
		end
		OpsTwilio.text to: from, msg: msg
	end

	def flip_phones from_number, msg
		if from_number == "+17029727139"
			to_number = "+12152000475"
		else
			to_number = "+17029727139"
		end
		OpsTwilio.text to: to_number, msg: msg
	end

private

	def zapper_params
		params.require(:data).permit("Reference", "PaymentStatusId", "PSPData", "Amount", "ZapperId", "UpdatedDate")
	end
end



# {"ToCountry"=>"US",
#  "ToState"=>"CA",
#  "SmsMessageSid"=>"SMf936c25f0b7fc1b5a569ed29fe4c3375",
#  "NumMedia"=>"0",
#  "ToCity"=>"LOS ANGELES",
#  "FromZip"=>"",
#  "SmsSid"=>"SMf936c25f0b7fc1b5a569ed29fe4c3375",
#  "FromState"=>"NV",
#  "SmsStatus"=>"received",
#  "FromCity"=>"",
#  "Body"=>"Andtoid rocking ",
#  "FromCountry"=>"US",
#  "To"=>"+13107364884",
#  "ToZip"=>"90240",
#  "NumSegments"=>"1",
#  "MessageSid"=>"SMf936c25f0b7fc1b5a569ed29fe4c3375",
#  "AccountSid"=>"ACa3fd35ae074a400b0af789bf7c71b0c4",
#  "From"=>"+17029727139",
#  "ApiVersion"=>"2010-04-01"}
