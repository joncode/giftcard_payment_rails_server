class EpsonPrinterDailyIssuesReportSysAlert < Alert

	# description:
	# Send a summary of all printers requiring attention (critical issue + offline count)

#   -------------

	def text_msg
		data = get_data

		sms  = "Daily IOM Epson Issues Report: "
		sms += "#{data[:attention]} printers have critical issues"
		sms += "; #{data[:offline].count} of them are OFFLINE"  unless data[:offline].empty?
		sms += ". See https://admin.itson.me/epson_printers for details."
		sms
	end

	def email_msg
		data = get_data

		markup  = "<h3>Epson Printer Daily Issues Report</h3>"
		markup += "<strong>There are #{data[:attention]} printers with critical issues"
		markup += "; <span style=\"color: firebrick\">#{data[:offline].count} of them are OFFLINE</span>"  unless data[:offline].empty?
		markup += ".</strong>"

		unless data[:offline].empty?
			markup += "<br/><br/>"
			markup += "Here's the list of offline printers:<br/>"
			markup += "<ul>"
			data[:offline].each do |name|
				markup += "<li>#{name}</li>"
			end
			markup += "</ul>"
		end

		markup += "<br/>"
		markup += "Open the <a href=\"https://admin.itson.me/epson_printers\">printer tracking page</a> for more information."

		markup.html_safe
	end

	def msg
		text_msg
	end

#   -------------

	def get_data
		data = { attention: 0, offline: [] }
		# Order printers by offline duration
		EpsonPrinter.all.order(last_poll_capture_at: :asc).each do |printer|
			if printer.offline? || printer.paper_out? || printer.cover_left_open? \
				|| printer.has_recent_mechanical_error? || printer.has_recent_cutter_error?
				data[:attention] += 1
			end
			next  unless printer.offline?
			data[:offline] << (printer.client.partner.name  rescue "(error; printer ##{printer.id})" )
		end

		data
	end

end