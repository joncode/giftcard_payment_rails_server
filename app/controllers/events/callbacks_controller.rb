class Events::CallbacksController < MetalCorsController

	include MtSmsRedeem

	def receive_sms
		msg = params['Body']
		from_number = params['From']

		# msg = Message.create(params)

		decide_what_to_do(from_number, msg, params)

		head :ok
	end


	def decide_what_to_do from, msg, req
		if code = Message.merchant_redemption(msg)
			mt_user = get_mt_user_with_number from
			if mt_user
				gift = find_gift_if_mt_user_has_notified_gifts(mt_user, code)
				if gift
					OpsTwilio.text to: from, msg: "We are redeeming #{gift.id} - #{code}"
				else
					OpsTwilio.text to: from, msg: "No Gift was found for code = #{code}"
				end
			else
				OpsTwilio.text to: from, msg: "No Merchant Tools user was found for this number"
			end

		elsif ["+12152000475","+17029727139"].include?(from)
			flip_phones from, msg
		end
	end

	def flip_phones from_number, msg
		if from_number == "+17029727139"
			to_number = "+12152000475"
		else
			to_number = "+17029727139"
		end
		OpsTwilio.text to: to_number, msg: msg
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
