class BookingSysAlert < BookingMtAlert

#############   THIS FILE IS AN INHERITS BookingMtAlert
#######

#   -------------

	def text_msg
		get_data
		"Booking Concierge Alert\n#{@data}"
	end

	def email_msg
		get_data
		"<div><h2>Booking Concierge Alert</h2><p>#{@data}</p></div>".html_safe
	end

	def msg
		text_msg
	end

#   -------------

	def get_data
		@data = booking.serialize
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
