RSpec.configure do |config|

	config.after(:each, type: :controller) do
    	if response
      	    example_group = example.metadata[:example_group]
    	    example_groups = []
    
	  	    while example_group
	    	    example_groups << example_group
	    	    example_group = example_group[:example_group]
	    	end
	    
	    	file_name = example_groups[-1][:description_args].first
	    
	    	File.open(File.join(Rails.root, "/docs/#{file_name}.txt"), 'a') do |f|
	    	    f.write "---------------------------------------------------------------- \n\n"
	    		f.write "LAST UPDATED: #{Time.now.strftime("%F")} \n\n\n\n"
	    	    f.write "Route: #{request.env['PATH_INFO']} \n\n"
	    		f.write "HTTP Method: #{request.env['REQUEST_METHOD']} \n\n"
	  	        if request.env['HTTP_TKN']
	  	        	if request.env['HTTP_TKN'].to_s == GENERAL_TOKEN
	  	        		request_token = "GENERAL_TOKEN"
	  	        	else
	  	        		request_token = request.env['HTTP_TKN']
	  	        	end
	    	        f.write "Authorization: ['HTTP_TKN'] = #{request_token} \n\n"
	    	    end
	    
	  	        request_parameters = request.env["action_dispatch.request.parameters"]["id"]		
	          	f.write "Request Parameters: #{request_parameters.present? ? request_parameters : "no parameters"} \n\n"
	    	    
	    	    f.write "Response Code: #{response.status} \n\n"
	    
	    		response_body = response.body
	    	    if response_body.present?
	    	    	parsed_response = print_first_two_if_array_is_large(JSON.parse(response_body))
	    	        f.write "Response Body: \n\n"
	    	        f.write "#{JSON.pretty_generate(parsed_response)} \n\n"
	    	    end
	    	    f.write "---------------------------------------------------------------- \n"
    		end unless response.status == 401 || response.status == 403 || response.status == 301
   		end
	end

	def print_first_two_if_array_is_large parsed_response
    	if parsed_response.class == Hash && parsed_response["status"].present? && parsed_response["data"].present?
    		# if response is an array of gifts
    		if parsed_response["data"].class == Array && parsed_response["data"].count > 2
    			parsed_response["data"] = parsed_response["data"][0..1]
    		# Else, if gifts_controller_spec, which has a hash
    		elsif parsed_response["data"].class == Hash
    			if parsed_response["data"]["sent"].class == Array && parsed_response["data"]["sent"].count > 2
    				parsed_response["data"]["sent"] = parsed_response["data"]["sent"][0..1]
    			end
    			if parsed_response["data"]["used"].class == Array && parsed_response["data"]["used"].count > 2
    				parsed_response["data"]["used"] = parsed_response["data"]["used"][0..1]
    			end
    			if parsed_response["data"]["gifts"].class == Array && parsed_response["data"]["gifts"].count > 2
    				parsed_response["data"]["gifts"] = parsed_response["data"]["gifts"][0..1]
    			end
    		end
    	elsif parsed_response.class == Array
    		if parsed_response.count > 2
    			parsed_response = parsed_response[0..1]
    		end	    	    		
    	end
    	parsed_response
	end

# ---- example.metadata --------
# {:example_group=>
# 	{:example_group=>
# 		{:description_args=>[Mdot::V2::BrandsController], 
# 		 :caller=>["/Users/umehara/.rvm/gems/ruby-1.9.2-p320@global/gems/rspec-core-2.13.1/lib/rspec/core/example_group.rb:289:in `set_it_up'", "/Users/umehara/.rvm/gems/ruby-1.9.2-p320@global/gems/rspec-core-2.13.1/lib/rspec/core/example_group.rb:241:in `subclass'", "/Users/umehara/.rvm/gems/ruby-1.9.2-p320@global/gems/rspec-core-2.13.1/lib/rspec/core/example_group.rb:228:in `describe'", "/Users/umehara/.rvm/gems/ruby-1.9.2-p320@global/gems/rspec-core-2.13.1/lib/rspec/core/dsl.rb:18:in `describe'", "/Users/umehara/rails/dbapp/spec/controllers/mdot/v2/brands_controller_spec.rb:3:in `<top (required)>'", "/Users/umehara/.rvm/gems/ruby-1.9.2-p320@global/gems/rspec-core-2.13.1/lib/rspec/core/configuration.rb:819:in `load'", "/Users/umehara/.rvm/gems/ruby-1.9.2-p320@global/gems/rspec-core-2.13.1/lib/rspec/core/configuration.rb:819:in `block in load_spec_files'", "/Users/umehara/.rvm/gems/ruby-1.9.2-p320@global/gems/rspec-core-2.13.1/lib/rspec/core/configuration.rb:819:in `each'", "/Users/umehara/.rvm/gems/ruby-1.9.2-p320@global/gems/rspec-core-2.13.1/lib/rspec/core/configuration.rb:819:in `load_spec_files'", "/Users/umehara/.rvm/gems/ruby-1.9.2-p320@global/gems/rspec-core-2.13.1/lib/rspec/core/command_line.rb:22:in `run'", "/Users/umehara/.rvm/gems/ruby-1.9.2-p320@global/gems/rspec-core-2.13.1/lib/rspec/core/runner.rb:80:in `run'", "/Users/umehara/.rvm/gems/ruby-1.9.2-p320@global/gems/rspec-core-2.13.1/lib/rspec/core/runner.rb:17:in `block in autorun'"],
# 		 :file_path=>"./spec/controllers/mdot/v2/brands_controller_spec.rb", 
# 		 :line_number=>3}, 

# 		 :description_args=>[:index], 
# 		 :caller=>["/Users/umehara/.rvm/gems/ruby-1.9.2-p320@global/gems/rspec-core-2.13.1/lib/rspec/core/example_group.rb:289:in `set_it_up'", "/Users/umehara/.rvm/gems/ruby-1.9.2-p320@global/gems/rspec-core-2.13.1/lib/rspec/core/example_group.rb:241:in `subclass'", "/Users/umehara/.rvm/gems/ruby-1.9.2-p320@global/gems/rspec-core-2.13.1/lib/rspec/core/example_group.rb:228:in `describe'", "/Users/umehara/rails/dbapp/spec/controllers/mdot/v2/brands_controller_spec.rb:13:in `block in <top (required)>'", "/Users/umehara/.rvm/gems/ruby-1.9.2-p320@global/gems/rspec-core-2.13.1/lib/rspec/core/example_group.rb:242:in `module_eval'", "/Users/umehara/.rvm/gems/ruby-1.9.2-p320@global/gems/rspec-core-2.13.1/lib/rspec/core/example_group.rb:242:in `subclass'", "/Users/umehara/.rvm/gems/ruby-1.9.2-p320@global/gems/rspec-core-2.13.1/lib/rspec/core/example_group.rb:228:in `describe'", "/Users/umehara/.rvm/gems/ruby-1.9.2-p320@global/gems/rspec-core-2.13.1/lib/rspec/core/dsl.rb:18:in `describe'", "/Users/umehara/rails/dbapp/spec/controllers/mdot/v2/brands_controller_spec.rb:3:in `<top (required)>'", "/Users/umehara/.rvm/gems/ruby-1.9.2-p320@global/gems/rspec-core-2.13.1/lib/rspec/core/configuration.rb:819:in `load'", "/Users/umehara/.rvm/gems/ruby-1.9.2-p320@global/gems/rspec-core-2.13.1/lib/rspec/core/configuration.rb:819:in `block in load_spec_files'", "/Users/umehara/.rvm/gems/ruby-1.9.2-p320@global/gems/rspec-core-2.13.1/lib/rspec/core/configuration.rb:819:in `each'", "/Users/umehara/.rvm/gems/ruby-1.9.2-p320@global/gems/rspec-core-2.13.1/lib/rspec/core/configuration.rb:819:in `load_spec_files'", "/Users/umehara/.rvm/gems/ruby-1.9.2-p320@global/gems/rspec-core-2.13.1/lib/rspec/core/command_line.rb:22:in `run'", "/Users/umehara/.rvm/gems/ruby-1.9.2-p320@global/gems/rspec-core-2.13.1/lib/rspec/core/runner.rb:80:in `run'", "/Users/umehara/.rvm/gems/ruby-1.9.2-p320@global/gems/rspec-core-2.13.1/lib/rspec/core/runner.rb:17:in `block in autorun'"], 
# 		 :file_path=>"./spec/controllers/mdot/v2/brands_controller_spec.rb", 
# 		 :line_number=>13, 
# 		 :described_class=>Mdot::V2::BrandsController, 
# 		 :describes=>Mdot::V2::BrandsController}, 
# 		 :example_group_block=>#<Proc:0x007fccb4db8c00@/Users/umehara/rails/dbapp/spec/controllers/mdot/v2/brands_controller_spec.rb:13>, :type=>:controller, :description_args=>["should return a list of brands"], :caller=>["/Users/umehara/.rvm/gems/ruby-1.9.2-p320@global/gems/rspec-core-2.13.1/lib/rspec/core/metadata.rb:185:in `for_example'", "/Users/umehara/.rvm/gems/ruby-1.9.2-p320@global/gems/rspec-core-2.13.1/lib/rspec/core/example.rb:81:in `initialize'", "/Users/umehara/.rvm/gems/ruby-1.9.2-p320@global/gems/rspec-core-2.13.1/lib/rspec/core/example_group.rb:65:in `new'", "/Users/umehara/.rvm/gems/ruby-1.9.2-p320@global/gems/rspec-core-2.13.1/lib/rspec/core/example_group.rb:65:in `it'", "/Users/umehara/rails/dbapp/spec/controllers/mdot/v2/brands_controller_spec.rb:28:in `block (2 levels) in <top (required)>'", "/Users/umehara/.rvm/gems/ruby-1.9.2-p320@global/gems/rspec-core-2.13.1/lib/rspec/core/example_group.rb:242:in `module_eval'", "/Users/umehara/.rvm/gems/ruby-1.9.2-p320@global/gems/rspec-core-2.13.1/lib/rspec/core/example_group.rb:242:in `subclass'", "/Users/umehara/.rvm/gems/ruby-1.9.2-p320@global/gems/rspec-core-2.13.1/lib/rspec/core/example_group.rb:228:in `describe'", "/Users/umehara/rails/dbapp/spec/controllers/mdot/v2/brands_controller_spec.rb:13:in `block in <top (required)>'", "/Users/umehara/.rvm/gems/ruby-1.9.2-p320@global/gems/rspec-core-2.13.1/lib/rspec/core/example_group.rb:242:in `module_eval'", "/Users/umehara/.rvm/gems/ruby-1.9.2-p320@global/gems/rspec-core-2.13.1/lib/rspec/core/example_group.rb:242:in `subclass'", "/Users/umehara/.rvm/gems/ruby-1.9.2-p320@global/gems/rspec-core-2.13.1/lib/rspec/core/example_group.rb:228:in `describe'", "/Users/umehara/.rvm/gems/ruby-1.9.2-p320@global/gems/rspec-core-2.13.1/lib/rspec/core/dsl.rb:18:in `describe'", "/Users/umehara/rails/dbapp/spec/controllers/mdot/v2/brands_controller_spec.rb:3:in `<top (required)>'", "/Users/umehara/.rvm/gems/ruby-1.9.2-p320@global/gems/rspec-core-2.13.1/lib/rspec/core/configuration.rb:819:in `load'", "/Users/umehara/.rvm/gems/ruby-1.9.2-p320@global/gems/rspec-core-2.13.1/lib/rspec/core/configuration.rb:819:in `block in load_spec_files'", "/Users/umehara/.rvm/gems/ruby-1.9.2-p320@global/gems/rspec-core-2.13.1/lib/rspec/core/configuration.rb:819:in `each'", "/Users/umehara/.rvm/gems/ruby-1.9.2-p320@global/gems/rspec-core-2.13.1/lib/rspec/core/configuration.rb:819:in `load_spec_files'", "/Users/umehara/.rvm/gems/ruby-1.9.2-p320@global/gems/rspec-core-2.13.1/lib/rspec/core/command_line.rb:22:in `run'", "/Users/umehara/.rvm/gems/ruby-1.9.2-p320@global/gems/rspec-core-2.13.1/lib/rspec/core/runner.rb:80:in `run'", "/Users/umehara/.rvm/gems/ruby-1.9.2-p320@global/gems/rspec-core-2.13.1/lib/rspec/core/runner.rb:17:in `block in autorun'"], :execution_result=>{:started_at=>2013-11-08 13:54:42 -0500}} -------------



# ----- EXAMPLE REQUEST ----
# <ActionController::TestRequest:0x007f8f32a9e688 
# @env={"rack.version"=>[1, 1], 
#       "rack.input"=>#<StringIO:0x007f8f31f973c0>, 
#       "rack.errors"=>#<StringIO:0x007f8f373b7478>, 
#       "rack.multithread"=>true, 
#       "rack.multiprocess"=>true, 
#       "rack.run_once"=>false, 
#       "REQUEST_METHOD"=>"GET", 
#       "SERVER_NAME"=>"example.org", 
#       "SERVER_PORT"=>"80", 
#       "QUERY_STRING"=>"", 
#       "rack.url_scheme"=>"http", 
#       "HTTPS"=>"off", 
#       "SCRIPT_NAME"=>nil, 
#       "CONTENT_LENGTH"=>"0", 
#       "action_dispatch.routes"=>#<ActionDispatch::Routing::RouteSet:0x007f8f375d7050>, 
#       "action_dispatch.parameter_filter"=>[:password, :password_confirmation, :password_digest, :token, :remember_token, :merchant_token, :merchant_tkn, :uid, :credit_number, :card_number, :verification_value, :confirm_email_token, :confirm_phone_token], 
#       "action_dispatch.secret_token"=>"80cb854c626de01bc9fce3ffdbb7c83961ca54311520874da313b8bb98eeeb3e343843187d0b743604ff43963bb43d0f62f4e13265d3776a9cae2912eb1a2687", 
#       "action_dispatch.show_exceptions"=>false, 
#       "action_dispatch.show_detailed_exceptions"=>true, 
#       "action_dispatch.logger"=>#<ActiveSupport::TaggedLogging:0x007f8f37338600 @logger=#<Logger:0x007f8f37338808 
#       																			@progname=nil, @level=1, 
#       																			@default_formatter=#<Logger::Formatter:0x007f8f373387b8 @datetime_format=nil>, 
#       																																	@formatter=#<Logger::SimpleFormatter:0x007f8f373386c8 @datetime_format=nil>, 
#       																																	@logdev=#<Logger::LogDevice:0x007f8f37338768 @shift_size=nil, @shift_age=nil, @filename=nil, @dev=#<IO:<STDOUT>>, @mutex=#<Logger::LogDevice::LogDeviceMutex:0x007f8f37338740 @mon_owner=nil, @mon_count=0, @mon_mutex=#<Mutex:0x007f8f373386f0>>>>>, "action_dispatch.backtrace_cleaner"=>#<Rails::BacktraceCleaner:0x007f8f350ae0a8 @filters=[#<Proc:0x007f8f350adb58@/Users/umehara/.rvm/gems/ruby-1.9.2-p320@global/gems/railties-3.2.11/lib/rails/backtrace_cleaner.rb:10>, #<Proc:0x007f8f350adb08@/Users/umehara/.rvm/gems/ruby-1.9.2-p320@global/gems/railties-3.2.11/lib/rails/backtrace_cleaner.rb:11>, #<Proc:0x007f8f350adae0@/Users/umehara/.rvm/gems/ruby-1.9.2-p320@global/gems/railties-3.2.11/lib/rails/backtrace_cleaner.rb:12>, #<Proc:0x007f8f350ad608@/Users/umehara/.rvm/gems/ruby-1.9.2-p320@global/gems/railties-3.2.11/lib/rails/backtrace_cleaner.rb:26>], @silencers=[#<Proc:0x007f8f350ad5e0@/Users/umehara/.rvm/gems/ruby-1.9.2-p320@global/gems/railties-3.2.11/lib/rails/backtrace_cleaner.rb:15>]>, 
# 	  "HTTP_HOST"=>"test.host", 
# 	  "REMOTE_ADDR"=>"0.0.0.0", 
# 	  "HTTP_USER_AGENT"=>"Rails Testing", 
# 	  "rack.session"=>{}, 
# 	  "rack.session.options"=>{:key=>"rack.session", :path=>"/", :domain=>nil, :expire_after=>nil, :secure=>false, :httponly=>true, :defer=>false, :renew=>false, :sidbits=>128, :cookie_only=>true, :secure_random=>SecureRandom, :id=>"7a1fe08fbe958f76a4833fbe47c9c861"}, 
# 	  "HTTP_TKN"=>"TokenGood", 
# 	  "action_dispatch.request.query_parameters"=>{}, 
# 	  "action_dispatch.cookies"=>#<ActionDispatch::Cookies::CookieJar:0x007f8f31fe5818 @secret="80cb854c626de01bc9fce3ffdbb7c83961ca54311520874da313b8bb98eeeb3e343843187d0b743604ff43963bb43d0f62f4e13265d3776a9cae2912eb1a2687", @set_cookies={}, @delete_cookies={}, @host="test.host", @secure=false, @closed=false, @cookies={}>, "rack.request.cookie_hash"=>{}, "action_dispatch.request.path_parameters"=>{"format"=>"json", "id"=>"1521", "controller"=>"mdot/v2/brands", "action"=>"merchants"}, "action_dispatch.request.content_type"=>nil, "action_dispatch.request.request_parameters"=>{}, "action_dispatch.request.flash_hash"=>#<ActionDispatch::Flash::FlashHash:0x007f8f31f972f8 @used=#<Set: {}>, @closed=false, @flashes={}, @now=nil>, 
# 	  "PATH_INFO"=>"/mdot/v2/brands/1521/merchants", 
# 	  "action_dispatch.request.parameters"=>{"format"=>"json", "id"=>"1521", "controller"=>"mdot/v2/brands", "action"=>"merchants"}, 
# 	  "action_dispatch.request.formats"=>[application/json]}, @formats=nil, @symbolized_path_params={:format=>"json", :id=>"1521", :controller=>"mdot/v2/brands", :action=>"merchants"}, @request_method="GET", @method="GET", @protocol="http://", @remote_ip=nil, @ip=nil, @fullpath="/mdot/v2/brands/1521/merchants", @set_cookies={}, @cookies={}, @port=80, @filtered_parameters={"format"=>"json", "id"=>"1521", "controller"=>"mdot/v2/brands", "action"=>"merchants"}> -------------

end