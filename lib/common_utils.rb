module CommonUtils

	def log_message_header
		"#{params["controller"].upcase} -#{params["action"].upcase}-"
	end

	def method_start_log_message
		x = params.dup
		x.delete('controller')
		x.delete('action')
		x.delete('format')
		puts "#{log_message_header} request: #{x}"
	end

	def method_end_log_message
		print "END #{log_message_header} "
		puts "response: #{@app_response[0..200]}" if @app_response
	end

end