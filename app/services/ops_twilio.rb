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
			# Note: As Twilio MMS messages take much longer to send (5+ seconds), this will arrive last.
			if media_url.present?
				text(to: to, msg: nil, media_url: media_url)
			end

			new_ary.map do |m|
				text(to: to, msg: m)
			end

		end

		def text to:, msg:, media_url:nil
			_signature = "[service OpsTwilio :: text(to:#{to})]"

			puts "#{_signature}"
			puts " | msg: #{msg}"              if msg
			puts " | media_url: #{media_url}"  if media_url

			if Rails.env.development? || Rails.env.test?
				return {status: 1, data: "Text send to #{to}"}
			end

			# Clean the phone number
			to.gsub!(/[^0-9]/, '')
			to = '1' + to if to.length == 10
			to = '+' + to

			# msg = ReceivedMessage.create(params)

			# Construct Twilio params
			# Twilio is very particular: 'body' must be passed, even when nil  (e.g. MMS with no text)
			options = {
				from:      TWILIO_PHONE_NUMBER,
				to:        to,
				body:      msg,
			}

			# Twilio is very particular: `media_url` must be omitted if nil.
			options[:media_url] = media_url  if media_url.present?

			begin
			    client = Twilio::REST::Client.new(TWILIO_ACCOUNT_SID, TWILIO_AUTH_TOKEN)
			    message = client.messages.create(options)
			    return { status: 1, data: message }
			rescue => e
				puts "#{_signature}  Error: #{e.inspect}"
			    return { status: 0, data: e }
			end

		end

		def text_devs msg:
			return
			text to: DEVELOPER_TEXT, msg: msg
		end

	end


end