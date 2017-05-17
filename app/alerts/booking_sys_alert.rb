class BookingSysAlert < BookingMtAlert

#############   THIS FILE IS AN INHERITS BookingMtAlert
#######


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
