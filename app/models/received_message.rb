class ReceivedMessage #< ActiveRecord::Base

	attr_accessor :body, :from, :sms_id


	def init_twilio hsh, user_id
		# new {body: hsh['Body'], from: hsh['From'], sms_id: hsh['SmsSid'],
		# 	mstr: 'twilio', rawj: hsh.to_json }
	end

	def self.create msg_params

	end



	def self.merchant_redemption msg
			# returns 4-digit code or nil
		return nil unless msg.to_i > 0 && msg.length == 4
		msg.to_i
	end




end


# {"ToCountry"=>"US",
#  "ToZip"=>"90240",
#  "ToState"=>"CA",
#  "ToCity"=>"LOS ANGELES",
#  "To"=>"+13107364884",
#  "NumMedia"=>"0",
#  "NumSegments"=>"1",
#  "FromCountry"=>"US",
#  "FromZip"=>"",
#  "FromState"=>"NV",
#  "FromCity"=>"",
#  "From"=>"+17029727139",
#  "SmsStatus"=>"received",
#  "Body"=>"Andtoid rocking ",
#  "SmsSid"=>"SMf936c25f0b7fc1b5a569ed29fe4c3375",
#  "SmsMessageSid"=>"SMf936c25f0b7fc1b5a569ed29fe4c3375",
#  "MessageSid"=>"SMf936c25f0b7fc1b5a569ed29fe4c3375",
#  "AccountSid"=>"ACa3fd35ae074a400b0af789bf7c71b0c4",
#  "ApiVersion"=>"2010-04-01"}