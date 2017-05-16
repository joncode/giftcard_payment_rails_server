class EmailBooking < EmailAbstract

	def initialize booking, template, subject
		super()
		email_data_hsh = {
			"subject" => subject,
			"html"    => "<div><p>#{booking.name}</p></div>".html_safe,
			"email"   => booking.email,
			"name"	  => booking.name
		}
		data = email_data_hsh
		@template = template
		@subject = email_data_hsh['subject']
		@body = email_data_hsh['html']
		@to_emails  = [{"email" => email_data_hsh['email'], "name" => email_data_hsh['name'] }]
		set_email_message_data
	end


end