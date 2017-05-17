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

