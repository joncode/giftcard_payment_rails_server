class JsonController < ActionController::Base

	skip_before_filter 	:verify_authenticity_token
	before_filter 		:method_start_log_message
	after_filter 		:cross_origin_allow_header
	after_filter 		:method_end_log_message

protected

  	def method_start_log_message
  		x = params.dup
  		x.delete('controller')
  		x.delete('action')
  		x.delete('format')
  		puts "#{log_message_header} request: #{x}"
  	end

  	def method_end_log_message
  		print "END #{log_message_header} "
  		puts "response: #{@app_response}" if @app_response
  	end

	def cross_origin_allow_header
		headers['Access-Control-Allow-Origin'] = "*"
		headers['Access-Control-Request-Method'] = '*'
	end	

	def authenticate_public_info(token=nil)
 		return true
	end

 	def unauthorized_user
 		{ "Failed Authentication" => "Please log out and re-log into app" }	
 	end

 	def database_error_redeem
 		{ "Data Transfer Error"   => "Please Reload Gift Center" }
 	end

 	def database_error_gift
 		{ "Data Transfer Error"   => "Please Retry Sending Gift" }
 	end

 	def database_error_general
 		{ "Data Transfer Error"   => "Please Reset App" }
 	end

 	def stringify_error_messages(object)
 		msgs = object.errors.messages
 		msgs.stringify_keys!
 		msgs.each_key do |key|
 			value_as_array 	= msgs[key]
 			if value_as_array.kind_of? Array
 				value_as_string = value_as_array.join(' | ')
 			else
 				value_as_string = value_as_array
 			end
 			msgs[key] 		= value_as_string
 		end

 		return msgs
 	end

private

	def log_message_header
  		"#{params["controller"].upcase} -#{params["action"].upcase}-"
  	end
end
