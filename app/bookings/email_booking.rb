class EmailBooking < EmailAbstract
	# inherits from /app/mailers/email_abstract.rb

	include ActionView::Helpers::NumberHelper
	include MoneyHelper


	def initialize booking, template, subject
		super()
		@booking = booking
		@book = booking.book
		@merchant = @booking.merchant
		@template = template
		@subject = subject
		@body = "<div><p>#{booking.name}</p></div>".html_safe
		@to_emails  = [{"email" => booking.email, "name" => booking.name }]
		set_bcc
		set_email_message_data
		set_vars
	end

	def set_vars
		h = { 	'book_name' => @booking.book_name,
				'booking_id' => @booking.hex_id,
				'booking_link' => @booking.customer_link,
				'merchant_name' => @merchant.name,
				'merchant_address' => @merchant.address,
				'merchant_city_state_zip' => @merchant.city_state_zip,
				'merchant_phone' => number_to_phone(@merchant.phone),
				'book_price_desc' => @booking.price_desc,
				'book_price' => display_money(ccy: @book.ccy, cents: @booking.price_unit),
				'guests' => @booking.guests,
				'booking_price_total' => display_money(ccy: @book.ccy, cents: @booking.price_total),
				'important' => (@booking.note || ''),
				'support_phone' => TWILIO_QUICK_NUM,
				'booking_date' => '',
				'primary_date' => '',
				'secondary_date' => ''
			}
		h['booking_date'] = format_date(@booking.event_at) if @booking.event_at.present?
		h['primary_date'] = format_date(@booking.date1) if @booking.date1.present?
		h['secondary_date'] = format_date(@booking.date2) if @booking.date2.present?
		set_vars_ary(h)
	end


end