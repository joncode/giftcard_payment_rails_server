class Events::CallbacksController < MetalCorsController
	# respond_to :json
	include MtSmsRedeem

	def receive_sms
		msg = params['Body']
		from_number = params['From']

		# msg = Message.create(params)

		dispatch_message(from_number, msg, params)

		# respond_with :ok

		respond_to do |format|
	     	format.json
	    end
	end

	def dispatch_message from, msg, req
		# if code = Message.merchant_redemption(msg)
		# 	redemption_msg from, code
		# elsif msg.downcase == 'support'
		# 	basic_support from
		# elsif ["+12152000475","+17029727139"].include?(from)
		# 	flip_phones from, msg
		# end
		OpsTwilio.text_devs msg: "Text -> #{req.inspect}"
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
