module CommonUtils

	def log_message_header
		"#{params["controller"].upcase} -#{params["action"].upcase}-"
	end

	def method_start_log_message
		x = params.dup
		x.delete('controller')
		x.delete('action')
		x.delete('format')
		@start_time_logger = Time.now
		puts "#{log_message_header} request: #{x}"
	end

	def method_end_log_message
		end_time = Time.now - @start_time_logger
		print "END #{log_message_header} Total time = #{end_time.round(3)}"
		puts "response: #{@app_response}" if @app_response
	end

end