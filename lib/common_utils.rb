
	####  MUST have FILTER_PARAMS loaded into Rails already

module CommonUtils
	include ActionView::Helpers::TextHelper

	def log_request_header

		if request.headers['App-Version']
			puts "HERE IS THE App-Version HEADER REQUEST #{request.headers['App-Version']}"
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
		puts "Here is the log params.dup = #{x}"
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
			log_text = @app_response.dup
			resp 	 = "#{filter_params(log_text)}"
			v 		 = "response: #{truncate(resp ,length: 600)}"
			v.gsub!('&quot;', '\'')
			v.gsub!('&gt;', '>')
			puts v
		end
	end

	def filter_params hash
		hsh = hash.dup
		if hsh.kind_of? Hash
			hsh = hash.dup
			filters = FILTER_PARAMS + FILTER_PARAMS.map {|fp| fp.to_s }
			filter_loop(hsh, filters)
		end
		hsh
	end

	def filter_loop(hsh, filters)
		hsh.each_key do |key|
			if filters.include? key
				hsh[key] = "[FILTERED]"
			else
				if hsh[key].kind_of?(Hash)
					value = hsh[key]
					filter_loop(value, filters)
				end
			end
		end
	end

end












