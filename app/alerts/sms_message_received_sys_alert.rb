class SmsMessageReceivedSysAlert < Alert

#############   THIS FILE IS AN ADMIN COPY OF GiftPurchasedMtAlert
#######

	def note
		self.target
	end

#   -------------

	def text_msg
		get_data
		"#{name_string}\n#{@data}"
	end

	def email_msg
		get_data
		"<div><h2>#{name_string}</h2><p>#{@data}</p></div>".html_safe
	end

	def msg
		text_msg
	end

#   -------------

	def get_data
		twilio_msg = self.target
		msg = twilio_msg['Body']
		from_number = twilio_msg['From']
		@data = "FROM: #{from_number}\n #{msg}"
	end

end




# gift is purchaed
# alert is called with gift as target
# init new alert
# is there a affiliate alert ?
	# get the affiliate of the gift merchant
	# find alert contacts for this alert for the affiliate
	# loop thru contacts and send the alerts
# is there a merchant alert
	# get the merchant for the gift
	# find alert contacts for this merchant
	# loop thru contacts and send the alerts
