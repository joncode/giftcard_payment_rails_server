require 'twilio-ruby'

class OpsTwilio

	class << self

		def link_text to: , link: , usr_msg: , system_msg: nil

			# 	3 steps to the process
			# 1 send the user to user message
			# 2. send the link
			# 3. send the company explanation
			indexed_msg = []
			[system_msg, link, usr_msg].each do |msg|
				next if msg.blank?
				indexed_msg << msg
			end
			total = indexed_msg.length
			new_ary = []
			indexed_msg = indexed_msg.each_with_index do |msg, i|
				new_ary << "#{i+ 1}/#{total}: #{msg}"
			end
			new_ary.each do |m|
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