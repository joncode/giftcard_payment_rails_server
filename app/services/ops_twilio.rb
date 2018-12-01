require 'twilio-ruby'

class OpsTwilio

	class << self

		def link_text to: , link: , usr_msg: , system_msg: nil, media_url: nil

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

			# Send the gift card image first, if present.
			if media_url.present?
				text(to: to, msg: nil, media_url: media_url)
				sleep(5)  # with a delay so there's a chance it arrives first.  (as Twilio's MMS takes much longer to send)
			end

			new_ary.map do |m|
				text(to: to, msg: m)
			end

		end

		def text to:, msg:, media_url:nil
			if Rails.env.development? || Rails.env.test?
				return {status: 1, data: "Text send to #{to}"}
			end

			# Clean the phone number
			to.gsub!(/[^0-9]/, '')
			to = '1' + to if to.length == 10
			to = '+' + to

			# msg = ReceivedMessage.create(params)

			# Compact our options because Twilio fails overdramatically if `media_url` is nil.
			options = {
				from:      TWILIO_PHONE_NUMBER,
				to:        to,
				body:      msg,
				media_url: media_url,
			}.compact

			begin
			    client = Twilio::REST::Client.new(TWILIO_ACCOUNT_SID, TWILIO_AUTH_TOKEN)
			    message = client.messages.create(options)
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