require 'twilio-ruby'

class OpsTwilio

	class << self


		def send_text


			account_sid = "{{ account_sid }}" # Your Account SID from www.twilio.com/console
			auth_token = "{{ auth_token }}"   # Your Auth Token from www.twilio.com/console

			begin
			    @client = Twilio::REST::Client.new account_sid, auth_token
			    message = @client.account.messages.create(:body => "Hello from Ruby",
			        :to => "+12345678901",    # Replace with your phone number
			        :from => "+12345678901")  # Replace with your Twilio number
			rescue Twilio::REST::RequestError => e
			    puts e.message
			end


		end


	end


end