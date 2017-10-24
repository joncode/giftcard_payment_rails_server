require 'twilio-ruby'

class OpsTwilio

	class << self

		def link_text to: , link: , usr_msg: , system_msg: nil

			# 3 steps to the process
			# 1 send the user to user message
			# 2. send the link
			# 3. send the company explanation
			usr_msg = "1/3: #{usr_msg}" unless usr_msg.blank?
			system_msg = "3/3: #{system_msg}" unless system_msg.blank?
			[usr_msg, link, system_msg].each do |m|
				next if m.blank?
				text(to: to, msg: m)
			end

		end

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