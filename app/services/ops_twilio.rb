require 'twilio-ruby'

class OpsTwilio

	class << self


		def text to:, msg:

			account_sid = TWILIO_ACCOUNT_SID
			auth_token = TWILIO_AUTH_TOKEN

			twilio_number = TWILIO_PHONE_NUMBER

			to.gsub!(/[^0-9]/, '')
			to = '1' + to if to.length == 10
			receiver_phone = "+" + to

			# msg = Message.create(params)

			begin
			    client = Twilio::REST::Client.new account_sid, auth_token
			    message = client.account.messages.create(
			    	:body => msg,
			        :to => receiver_phone,
			        :from => twilio_number)
			rescue Twilio::REST::RequestError => e
			    puts e.message.to_s + "\nOpsTwilio(26)"
			end

		end


	end


end