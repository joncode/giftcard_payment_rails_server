
	####  MUST have FILTER_PARAMS loaded into Rails already

module CommonUtils
	include ActionView::Helpers::TextHelper

	def log_request_header
		if request.headers['app_version']
			puts "HERE IS THE HEADER REQUEST #{request.headers['app_version']}"
		end

		if request.headers["HTTP_COOKIE"]
			puts "HERE IS THE HEADER #{request.headers["HTTP_COOKIE"]}"
		end
	end

	def log_message_header
		"#{params["controller"].upcase} -#{params["action"].upcase}-"
	end

	def method_start_log_message
		x = params.dup
		x.delete('controller')
		x.delete('action')
		x.delete('format')
		@start_time_logger = Time.now
		puts
		puts "#{log_message_header} request: #{filter_params(x)}"
	end

	def method_end_log_message
		end_time = Time.now - @start_time_logger
		print "END #{log_message_header} Total time = #{end_time.round(3)}s | "
		if @app_response
			resp = "#{filter_params(@app_response)}"
			puts "response: #{truncate(resp ,length: 600)}"
		end
	end

	def filter_params hsh
		if hsh.kind_of? Hash
			filter_text 	= "[FILTERED]"
			filters 		= FILTER_PARAMS + FILTER_PARAMS.map {|fp| fp.to_s }

			hsh.keys.each do |k|
			   if filters.include? k
			   	hsh[k] = filter_text
			   end
			end
		end
	    hsh
	end

end