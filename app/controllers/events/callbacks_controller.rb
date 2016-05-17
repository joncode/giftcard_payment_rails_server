class Events::CallbacksController < MetalCorsController

	def receive_sms
		msg = params['Body']
		from_number = params['From']
		if from_number == "+17029727139"
			to_number = "+12152000475"
		else
			to_number = "+17029727139"
		end
		OpsTwilio.text to: to_number, msg: msg

		head :ok
	end



private


	# def twilio_params
	# 	params.
	# end


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
