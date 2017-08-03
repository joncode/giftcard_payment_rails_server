require 'twilio-ruby'

class OpsTwilio

	class << self


		def text to:, msg:
			if Rails.env.development? || Rails.env.test?
				return {status: 1, data: "Text send to #{to}"}
			end
			account_sid = TWILIO_ACCOUNT_SID
			auth_token = TWILIO_AUTH_TOKEN

			twilio_number = TWILIO_PHONE_NUMBER

			to.gsub!(/[^0-9]/, '')
			to = '1' + to if to.length == 10
			receiver_phone = "+" + to

			# msg = ReceivedMessage.create(params)

			begin
			    client = Twilio::REST::Client.new account_sid, auth_token
			    message = client.messages.create(
			    	:body => msg,
			        :to => receiver_phone,
			        :from => twilio_number)
			    return { status: 1, data: message }
			rescue => e
			    puts e.inspect + " - OpsTwilio(31) 500 Internal"
			    return { status: 0, data: e }
			end

		end

		def text_devs msg:
			return
			text to: DEVELOPER_TEXT, msg: msg
		end

	end


end