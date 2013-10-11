
	####  MUST have FILTER_PARAMS loaded into Rails already

module CommonUtils
	include ActionView::Helpers::TextHelper

	def log_request_header

		if request.headers['App-Version']
			puts "HERE IS THE App-Version HEADER REQUEST #{request.headers['App-Version']}"
		end

		if request.headers['Mdot-Version']
			puts "HERE IS THE Mdot-Version HEADER REQUEST #{request.headers['Mdot-Version']}"
		end

		if request.headers["HTTP_TKN"]
			puts "HERE IS THE HEADER TOKEN #{request.headers["HTTP_TKN"]}"
		end

		if request.headers["HTTP_COOKIE"]
			puts "HERE IS THE HEADER #{request.headers["HTTP_COOKIE"]}"
		end
	end


	def log_message_header
		"#{params["controller"].upcase} -#{params["action"].upcase}-"
	end

	def marshal_copy obj
		begin
			dumper = Marshal.dump(obj)
			Marshal.load(dumper)
		rescue
			puts "Marshal copy FAIL common utils"
			{'controller' => obj["controller"] ,'action' => obj["action"],'format' => obj["format"] }
		end
	end

	def method_start_log_message
		x = marshal_copy(params)
		x.delete('controller')
		x.delete('action')
		x.delete('format')
		@start_time_logger = Time.now
		puts
		puts "#{log_message_header} request: #{filter_params(x)}"
	end

	def method_end_log_message
		end_time = ((Time.now - @start_time_logger) * 1000).round(1)
		print "END #{log_message_header} (#{end_time}ms) | "
		if @app_response
			log_text = marshal_copy(@app_response)
			resp 	 = "#{filter_params(log_text)}"
			v 		 = "response: #{truncate(resp ,length: 600)}"
			v.gsub!('&quot;', '\'')
			v.gsub!('&gt;', '>')
			puts v
		end
	end

	def filter_params hash
		hsh = hash
		if hsh.kind_of? Hash
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














