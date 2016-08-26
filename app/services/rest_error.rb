class RestError

	attr_reader :code, :message, :error

	def initialize e: nil, r: nil
		if e
			@code = e.http_code
			if e.response && e.response.respond_to?(:message)
				@message = e.response.message
			else
				@message = e.message
			end
			@error = e
		else
			r.stringify_keys!
			@code = r['code']
			@message = r['response_code'] + ' ' +r['response_text']
			@error = r
		end
	end


end