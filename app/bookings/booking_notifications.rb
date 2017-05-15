class BookingNotifications

#   -------------  CLASS API SURFACE

	class << self

		def send_inquiry_confirmation_to_customer booking_id
			puts "BookingNotifications.send_inquiry_confirmation_to_customer (8) - Booking #{booking_id}"

				# send email to customer confirming that we have received their inquiry
				# Send Alert to IOM team that inquiry has occurred
				# Send Alert to the Merchant that inquiry has occurred ?
			booking = Booking.find booking_id
		end

		def send_purchase_link_to_customer booking_id
			puts "BookingNotifications.send_purchase_link_to_customer (15) - Booking #{booking_id}"

				# send the purchase link to the accept and purchase booking page
			booking = Booking.find booking_id
		end

		def send_booking_confirmation_to_customer booking_id
			puts "BookingNotifications.send_booking_confirmation_to_customer (20) - Booking #{booking_id}"

				# send email to customer receipt - confirming purchase
				# Send Alert to IOM team that inquiry has occurred
				# Send Alert to the Merchant that inquiry has occurred ?
			booking = Booking.find booking_id
		end

		def send_email_reminder booking_id, days_till
			puts "BookingNotifications.send_email_reminder (27) - Booking #{booking_id} - Days #{days_till}"

			# send email to customer with reminder of the upcoming event
			booking = Booking.find booking_id
		end

	end



end