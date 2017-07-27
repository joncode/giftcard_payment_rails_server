class BookingMtAlert < Alert


    def booking
        self.target
    end

    def note
        self.target.merchant
    end

#   -------------

	def text_msg
		get_data
		"Top100 Booking Alert\n#{@data[:customer_name]} has booked the #{@data[:book_name]} top100 experience.\n Status has changed to '#{@data[:status]}'.\n Booking ID = #{@data[:hex_id]}\n"

	end

	def email_msg
		get_data
		"<div><h2>Top100 Booking Alert</h2>
<p>#{@data[:customer_name]} has booked the #{@data[:book_name]} top100 experience.</p>
<p>Booking status has changed to '#{@data[:status]}'</p>
<p>Booking ID = #{@data[:hex_id]}</p>
</div>".html_safe
	end

	def msg
		text_msg
	end


#   -------------

	def get_data
		@data = { customer_name: booking.name,
				book_name: booking.book_name,
				hex_id: booking.paper_id,
				status: booking.status.titleize
			}
	end

end



