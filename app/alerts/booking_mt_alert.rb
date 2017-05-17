class BookingMtAlert < Alert

#############   THIS FILE IS AN ADMIN COPY OF GiftPurchasedMtAlert
#######

	def booking
		self.target
	end

#   -------------

	def text_msg
		get_data
		"Booking Alert\n#{@data}"
	end

	def email_msg
		get_data
		"<div><h2>Booking Alert</h2><p>#{@data}</p></div>".html_safe
	end

	def msg
		text_msg
	end

#   -------------

	def get_data
		@data = booking.serialize
	end

end



