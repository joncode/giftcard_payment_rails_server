class AppController < ApplicationController

	include ActionView::Helpers::DateHelper
	skip_before_filter :verify_authenticity_token
	before_filter 	:method_start_log_message
	after_filter 	:cross_origin_allow_header
	after_filter 	:method_end_log_message

	UPDATE_REPLY  	= ["id", "first_name", "last_name" , "address" , "city" , "state" , "zip", "email", "phone", "birthday", "sex", "twitter", "facebook_id"]  
	GIFT_REPLY 	  	= ["giver_id", "giver_name", "provider_id", "provider_name", "message", "status"]
    MERCHANT_REPLY  = GIFT_REPLY + ["tax", "tip", "total", "order_num"]
    ACTIVITY_REPLY 	= GIFT_REPLY + [ "receiver_id", "receiver_name"] 

 	def authenticate_app_user(token)
 		if user = User.find_by_remember_token(token)
 			return user
 		else
 			return false
 		end
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

 	def stringify_error_messages(object)
 		msgs = object.errors.messages
 		msgs.stringify_keys!
 		msgs.each_key do |key|
 			value_as_array 	= msgs[key]
 			value_as_string = value_as_array.join(' | ')
 			msgs[key] 		= value_as_string
 		end

 		return msgs
 	end

  	def shorten_url_for_provider_ary providers_array
  		providers_array.each do |prov|
  			short_photo_url = short_photo_url prov["photo"]
  			prov["photo"] = short_photo_url
  		end
  	end

  	def shorten_url_for_brand_ary brands_array
  		brands_array.each do |brand|
  			short_photo_url = short_photo_url brand["photo"]
  			brand["photo"] = short_photo_url
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
  		puts "#{log_message_header} request: #{x}"
  	end

  	def method_end_log_message
  		print "END #{log_message_header} "
  		puts "response: #{@app_response}" if @app_response
  	end

  	def short_photo_url photo_url
  		url_ary = photo_url.split('upload/')
  		shorten_url = url_ary[1]

  		identifier, tag = shorten_url.split('.')

  		new_photo_ary = ['d', identifier , 'j']
  		if photo_url.match 'htaaxtzcv'
  			new_photo_ary[0] = 'h'
  		end

  		if !tag.match('jpg')
  			new_photo_ary[2] = tag.match('png') ? 'p' : tag
  		end

  		return new_photo_ary.join("|")
  	end

 	def update_user

 		response = {}
 		if user = authenticate_app_user(params["token"])
 		 			# user is authenticated
 		 	puts "App -Update_user- data = #{params["data"]}"
 		 	updates = JSON.parse params["data"]
 		 	puts "App -Update_user- parsed data = #{updates}"
 		else
 			# user is not authenticated
 			response["error"] = {"user" => "could not identity app user"}
 		end

 		respond_to do |format|
 			if user.update_attributes(updates)
	          response["success"]      = user.serializable_hash only: UPDATE_REPLY
	        else
	          response["error_server"] = stringify_error_messages user 
	        end
	    	puts "AC UpdateUSER response => #{response}"
	    	format.json { render json: response }
	    end	
 	end

 	def relays

 		response = {}
 		if user  = authenticate_app_user(params["token"])
 			# user is authenticated
 			gift_array 	= Gift.get_gifts(user)
 			badge 		= gift_array.size
 			if badge > 0
 				gift_array_to_app   = array_these_gifts(gift_array, GIFT_REPLY, true)
	 			response["success"] = { "badge" => badge, "gifts" => gift_array_to_app }
	 		else
	 			response["success"] = { "badge" => 0 }
	 		end
 		else
 			# user is not authenticated
 			response["error"] = {"user" => "could not identity app user"}
 		end
 		respond_to do |format|
	    	logger.debug "AC Relays response => badge = #{badge}"
	    	format.json { render json: response }
	    end
 	end

 	def menu

 		response = {}
	
 		if authenticate_public_info
 			provider_id  = params["data"]
 			response = []
 			response = MenuString.get_menu_for_provider(provider_id.to_i)
 			logmsg 	 = response[0]
 		else
 			response["error"] = "user was not found in database"
 			logmsg 	 = response
 		end
	    
	    respond_to do |format|
	    	# logger.debug response
	    	puts "AC Menu response => #{logmsg}"
	    	format.json { render json: response }
	    end
 	end

 	def gifts

	    if user = authenticate_app_user(params["token"])
	    	gifts 		= Gift.get_gifts(user)
	    	gifts_array = array_these_gifts(gifts, GIFT_REPLY, true)
	  		logmsg 		= gifts_array[0]
	  	else
	  		gift_hash 	= {"error" => "user was not found in database"}
	  		gifts_array = gift_hash
	  		logmsg 		= gift_hash
	  	end
	    respond_to do |format|
	      # logger.debug gifts_array
	      puts "AC Gifts response => #{logmsg}"
	      format.json { render json: gifts_array }
	    end
  	end

 	def orders
 			# send orders to the app for a provider

	    if user = authenticate_app_user(params["token"])
	    	provider 	= Provider.find(params["provider"])
    		gifts 		= Gift.get_history_provider(provider)
	    	gifts_array = array_these_gifts(gifts, MERCHANT_REPLY, false, true, true)
	  		logmsg 		= gifts_array[0]
	  	else
	  		gift_hash 	= {"error" => "user was not found in database"}
	  		gifts_array = gift_hash
	  		logmsg 		= gift_hash
	  	end
	    respond_to do |format|
	      # logger.debug gifts_array
	      puts "AC Orders response => #{logmsg}"
	      format.json { render json: gifts_array }
	    end
  	end

 	def merchant_redeem
 			# send orders to the app for a provider
	    response = {}
	    if user = authenticate_app_user(params["token"])
	    	data 				= JSON.parse params["data"]
    		employee 			= Employee.where(user_id: user.id, provider_id: data["provider_id"])[0]
	    	data["employee_id"] = employee.id if employee
	    	order  				= Order.new(data)
	    	puts "order = #{order.inspect}"
	  	else
	  		response["error"] = "user was not found in database"
	  		order 		= Order.new
	  	end
	    respond_to do |format|
	    	if order.save 
	    		#success
	    		response["success"] = "Order for Gift-#{order.gift_id} Completed!"
	    	else
	    		response["error_server"] = stringify_error_messages order
	    	end
	      	puts "AC -Merchant Redeem- response => #{response}"
	      	format.json { render json: response }
	    end
  	end

  	def user_activity

	    user  = User.find(params["user_id"])
	    if user 
	    	gifts 		= Gift.get_user_activity(user)
	    	gifts_array = array_these_gifts(gifts, ACTIVITY_REPLY, true, true)
	  		logmsg 		= gifts_array[0]
	  	else
	  		gift_hash 	= {"error" => "user was not found in database"}
	  		gifts_array = gift_hash
	  		logmsg 		= gift_hash
	  	end
	    respond_to do |format|
	      # logger.debug gifts_array
	      puts "AC UserActivity response[0] => #{logmsg}"
	      format.json { render json: gifts_array }
	    end
  	end

  	def past_gifts

	    if user = authenticate_app_user(params["token"])
	    	gifts 		= Gift.get_past_gifts(user)
	    	gifts_array = array_these_gifts(gifts, GIFT_REPLY, true)
	    	logmsg 		= gifts_array[0]
	  	else
	  		gift_hash 	= {"error" => "user was not found in database"}
	  		gifts_array = gift_hash
	  		logmsg 		= gift_hash
	  	end
	    respond_to do |format|
	      # logger.debug gifts_array
	      puts "AC PastGifts response[0] => #{logmsg}"
	      format.json { render json: gifts_array }
	    end
  	end

  	def questions
  		  		
  		if user = authenticate_app_user(params["token"])

		  	  	# save filled out answers to db
	  		if params["answers"]
	        	puts "ANSWERS #{params['answers']}"
	  			answered_questions = JSON.parse params["answers"]
	  			Answer.save_these(answered_questions, user)
	  		end

	  			# get new pack of questions
			begin
	  			response = Question.get_questions_with_answers(user)
	  		rescue
	  			response = ["error", "could not get questions"]
	  		end
	  	else
	  		response = ["error", "could not find user in db"]
	  	end

  		respond_to do |format|
	    	puts "AC Questions response => #{response}"
	    	format.json { render json: response }
	    end
  	end

 	def others_questions
  		# user  = User.find_by_remember_token(params["token"])
  		
  		begin  
  			other_user = User.find(params["user_id"])
	  			# get new pack of questions
			begin
	  			response = Question.get_questions_with_answers(other_user)
	  		rescue
	  			response = ["error", "could not get questions"]
	  		end
	  	rescue
	  		response = ["error", "could not find other user in db"]
	  	end
  		respond_to do |format|
	      	puts "AC OtherQuestions response => #{response}"
	      	format.json { render json: response }
	    end
  	end

  	def transactions

  		if user = authenticate_app_user(params["token"])
  			transaction_array = Gift.transactions(user)
  			logmsg 			  = transaction_array[0]
	  	else
	  		transaction_array = ["error", "could not find user in db"]
	  		logmsg 			  = "Error - Could not find user in db"
	  	end
  		respond_to do |format|
	      # logger.debug transaction_array
	      puts "AC Transactions response[0] => #{logmsg}"
	      format.json { render json: transaction_array }
	    end
  	end

  	def providers

	    if authenticate_public_info
	    	if  !params["city"] || params["city"] == "all"
	    		providers = Provider.all
	    	else
	    		providers = Provider.where(city: params["city"])
	    	end
	    	providers_array = serialize_objs_in_ary providers
	    	logmsg 			= providers_array[0]
	  	else
	  		providers_hash 	= {"error" => "user was not found in database"}
	  		providers_array = providers_hash
	  		logmsg 			= providers_hash
	  	end

  		respond_to do |format|
	      # logger.debug providers_array
	      puts "AC Providers response[0] => #{logmsg}"
	      format.json { render json: providers_array }
	    end
  	end

  	def providers_short_ph_url
	    if  authenticate_public_info
	    	if  !params["city"] || params["city"] == "all"
	    		providers = Provider.all
	    	else
	    		providers = Provider.where(city: params["city"])
	    	end
	    	providers_array = serialize_objs_in_ary providers
	    	providers_array = shorten_url_for_provider_ary providers_array
	    	logmsg 			= providers_array[0]
	  	else
	  		providers_hash 	= {"error" => "user was not found in database"}
	  		providers_array = providers_hash
	  		logmsg 			= providers_hash
	  	end

  		respond_to do |format|
	      # logger.debug providers_array
	      puts "AC ProvidersShortPhotoURL response[0] => #{logmsg}"
	      format.json { render json: providers_array }
	    end
  	end

  	def brands
  		if  authenticate_public_info
	    	if  !params["city"] || params["city"] == "all"
	    		brands = Brand.all
	    	else
	    		brands = Brand.where(city: params["city"])
	    	end
	    	brands_array 	= serialize_objs_in_ary brands
	    	# brands_array  = shorten_url_for_brand_ary brands_array
	    	logmsg 			= brands_array[0]
	  	else
	  		brands_hash 	= {"error" => "user was not found in database"}
	  		brands_array 	= brands_hash
	  		logmsg 			= brands_hash
	  	end

  		respond_to do |format|
	      # logger.debug providers_array
	      puts "AC Brands response[0] => #{logmsg}"
	      format.json { render json: brands_array }
	    end
  	end

  	def brand_merchants
	    if  authenticate_public_info
	    	brand_id = params["data"].to_i
	    	begin
	    		brand 			= Brand.find brand_id
	    		providers_array = serialize_objs_in_ary brand.providers
	    		# providers_array = shorten_url_for_provider_ary providers_array
	    		logmsg 			= providers_array[0]
	    	rescue
	    		logmsg 			= { "error_server" => { "data_error" => "Cant find Brand with that ID"}}
	    		providers_array = logmsg
	    	end
	  	else
	  		providers_hash 	= {"error" => "user was not found in database"}
	  		providers_array = providers_hash
	  		logmsg 			= providers_hash
	  	end

  		respond_to do |format|
	      # logger.debug providers_array
	      puts "AC BrandMerchants response[0] => #{logmsg}"
	      format.json { render json: providers_array }
	    end
  	end

	def drinkboard_users

		begin
			user = authenticate_app_user(params["token"])
			# @users = User.find(:all, :conditions => ["id != ?", @user.id])
			# providers = Provider.find(:all, :conditions => ["staff_id != ?", nil])
			if !params['city'] || params['city'] == 'all'
				users    = User.all
			else
				users    = User.find_by_city(params['city'])
			end 
			user_array = serialize_objs_in_ary users
			logmsg 	   = user_array[0]
		rescue 
			puts "ALERT - cannot find user from token"
			user_array = {"error" => "cannot find user from token"}
			logmsg 	   = user_array
		end


		respond_to do |format|
			# logger.debug user_array
			format.json { render json: user_array }
			puts "AC DbUSERS response[0] => #{logmsg}"
		end
	end

	def create_redeem_emps

    	message  = ""
    	response = {}
    	process  = false
    	gift_id  = params["data"]
    	gift_id  = gift_id.to_i

    	if gift_id.nil?
      		message = "data did not transfer. "
      		redeem  = Redeem.new
    	else
       		# receiving a gift_id from the iPhone here
     		if redeem = Redeem.find_by_gift_id(gift_id)
     			puts "FOUND GIFT REDEEM #{gift_id}"
     			process = true
     		else
 				if redeem  = Redeem.create(gift_id: gift_id)
 					process = true
 					puts "CREATED GIFT REDEEM #{gift_id}"
 				else
 					puts "FAILED TO CREATE GIFT REDEEM #{gift_id}"
 				end
     		end
    	end
    	begin
      		receiver = authenticate_app_user(params["token"])
    	rescue
      		message += "Couldn't identify app user. "
    	end

    	response = { "error" => message } if message != "" 
    	if redeem.provider.nil? 
    		process = false 
    		message += "Gift is missing a provider - GIFT ID = #{redeem.gift.id}"
    	end
		respond_to do |format|
			if process
				employees_ary = redeem.provider.employees_to_app
				redeem_code   = redeem.redeem_code.to_s
				response = [redeem_code, employees_ary]
			else
				message += " Gift unable to process to database. Please retry later."
				response["error_server"] = message 
			end
			puts "AC CreateRedeem response => #{response}"
			format.json { render json: response }
		end
  	end

  	def create_redeem
  		response = {}
  		# receive {"token" => "<token>", "data" => "<gift_id>" }
  					# authenticate user
  		if receiver = authenticate_app_user(params["token"])
  					# get gift from db
  			begin
	  			gift = Gift.find params["data"].to_i
	  					# find or create redeem for gift
	  						# if redeem exists app should not call server 
	  						# gift.status == "notified" if redeem exists
	  			redeem = Redeem.find_or_create_with_gift(gift)
	  			if redeem.redeem_code
	  				response["success"] = redeem.redeem_code.to_s
	  			else
	  				response["error_server"] = database_error_redeem
	  			end
	  		rescue
	  			response["error_server"] = database_error_redeem
	  		end
  		else
  			response["error"] = unauthorized_user
  		end

  		respond_to do |format|
  			puts "AC CreateRedeem response => #{response}"
  			format.json { render json: response}
  		end 		
  	end

  	def create_order
  		response = {}
  		# receive {"token" => "<token>", "data" => "<gift_id>" }
  		  			# authenticate user
  		if receiver = authenticate_app_user(params["token"])
  					# get gift from db
  			begin
	  			gift  = Gift.find params["data"].to_i
	  			order = Order.init_with_gift(gift)
	  			if order.save
	  				response["success"] = { "order_number" => order.make_order_num,  "tax" => gift.tax, "total" => gift.total, "tip" => gift.tip }
	  			else
	  				response["error_server"] = stringify_error_messages order
	  			end
	  		rescue
	  			response["error_server"] = database_error_redeem
	  		end
	  	else
  			response["error"] = unauthorized_user
  		end

  		respond_to do |format|
  			puts "AC CreateORDER response => #{response}"
  			format.json { render json: response}
  		end 
  	end

  	def create_gift
  		response = {}
  		gift_obj = JSON.parse params["gift"]
  		  			# authenticate user
  		if giver = authenticate_app_user(params["token"])
  					# check to see that the gift has the correct data to save
  					# check to see that the gift has a shoppingCart
			if gift_obj.nil? || params["shoppingCart"].nil?
						# nothing can be done without the data 
				response["error_server"] = "Data didnt arrive #{database_error_gift}"	
		    else
		    		# add the receiver + receiver checks to the gift object 
		        puts "Lets make this gift !!!"
		        add_receiver_by_origin(params["origin"], gift_obj, response)
		        gift    = Gift.new(gift_obj)
		        sc = JSON.parse params["shoppingCart"]
		        gift.make_gift_items(sc)
				puts "Made it thru original git making process"
	  				# add the giver info to the gift object
	  			if gift_obj["anon_id"]
			        gift.add_anonymous_giver(giver.id)
			    else
			      	gift.add_giver(giver)
			    end
			    gift.set_no_pay_status
	  			if giver.email == "test@test.com"
	  				gift.status = "unpaid"
	  			end
	  			puts "Here is GIFT #{gift.inspect}"
	  			if gift.save
	  				sale = gift.charge_card
			        if sale.resp_code == 1
			        	response["success"]       = {"Gift Created" => "Success!"}
			        else
			        	response["error_server"]  = { "Credit Card" => sale.reason_text }
			        end
	  			else
	  				response["error_server"] = stringify_error_messages gift
	  			end
	  		end
	  	else
  			response["error"] = unauthorized_user
  		end

  		respond_to do |format|
  			if response.has_key? "error_server"
  				@app_response = stringify_error_messages gift
  			end
  			@app_response = "AppC #{response}"
  			format.json { render json: response}
  		end 
  	end

	def create_order_emp

		message   = ""
		response  = {} 
		gift_id 	= params["gift_id"]
		employee_id = params["employee_id"]

		if gift_id.nil? || employee_id.nil? 
			message = "Data not received correctly. "
			order   = Order.new
		else
			order   = Order.new(gift_id: gift_id.to_i, employee_id: employee_id.to_i)
		end
		begin
			user 	= authenticate_app_user(params["token"])
		rescue
			message += "Couldn't identify app user. "
		end
		begin
			redeem   = Redeem.find_by_gift_id(gift_id)
			# putting redeem code in order from redeem altho likely not necessary
			order.redeem_code = redeem.redeem_code
		rescue
			message += " Could not find redeem code via gift_id. "
		end


		response = { "error" => message } if message != "" 

		respond_to do |format|
			if order.save
				response["success"]      = " Sale Confirmed. Thank you!"
			else
				response["error_server"] = stringify_error_messages order
			end
			puts "AC CreateOrder response => #{response}"
			format.json { render json: response }
		end
	end 

	def delete_card

		# message = ""
		response = {}

		if user = authenticate_app_user(params["token"])
			cCard = Card.find(params["data"])
			if cCard.user_id == user.id
				if cCard.destroy
					response["delete"] = "#{cCard.id}"
				else
					response["error_server"] = "#{cCard.nickname} #{cCard.id} could not be deleted"
				end
			end
		else
			response["error"] = "Couldn't identify app user. "
		end

		respond_to do |format|
			puts "AC DeleteCard response => #{response}"
			format.json { render json: response }
		end
	end 

	def get_cards

		message   = ""
		response  = {} 

      	if user = authenticate_app_user(params["token"])
      		display_cards = Card.get_cards user
      		if display_cards.empty?
      			response["success"] = []
      		else
      			response["success"] = display_cards
      		end
    	else
      		message += "Couldn't identify app user. "
      		response["error"] = message
    	end

    	respond_to do |format|
			puts "AC GetCards response => #{response}"
			puts message
			format.json { render json: response }
		end
	end

	def add_card

		message   = "" 
		response  = {} 

      	if user = authenticate_app_user(params["token"])
      		puts "User = #{user.fullname}"
      		puts "params data = #{params['data']}"
      		card_data = JSON.parse params["data"]
      		puts "card data post JSON = #{card_data}"
      		cCard = Card.create_card_from_hash card_data
      		puts "the new card object is = #{cCard.inspect}"
    	else
     	  	message += "Couldn't identify app user. "
     	  	cCard = nil;
    	end

    	respond_to do |format|
			#if message.empty?
				if cCard.save
					response["add"]      = "Card added"
					puts "here is the saved new ccard = #{cCard.inspect}"
				else
					response["error_server"] = stringify_error_messages cCard
				end
			#end
			puts "AC AddCard response => #{response}"
			puts message
			format.json { render json: response }
		end
		
	end

	def reset_password

		if params[:email]
			user = User.find_by_email(params[:email])
			if user
				user.update_reset_token
				Resque.enqueue(EmailJob, 'reset_password', user.id, {})  
				response = {"success" => "Email is Sent , check your inbox"}
			else
				response = {"error" => "We do not have record of that email"}
			end
		else
			response = {"error" => "no email sent"}
		end	

		respond_to do |format|
			format.json {render json: response }
		end	
	end

	def get_settings
  		  		
  		if user = authenticate_app_user(params["token"])
			begin
	  			response = {"success" => user.get_settings }
	  		rescue
	  			response = {"error" => "could not get settings"}
	  		end
	  	else
	  		response = {"error" => "could not find user in db"}
	  	end

  		respond_to do |format|
	    	puts "AC Settings response => #{response}"
	    	format.json { render json: response }
	    end		
	end

	def save_settings
  		response = {} 		
  		if user = authenticate_app_user(params["token"])
			data = JSON.parse params["data"]
	  		if user.save_settings(data)
	  			response = { "success" => "Settings saved" }
	  		else
	  			response["error_server"] = stringify_error_messages user
	  		end
	  	else
	  		response = { "error" => unauthorized_user }
	  	end

  		respond_to do |format|
	    	puts "AC Save Settings response => #{response}"
	    	format.json { render json: response }
	    end			
	end

	def save_settings_m
  		response = {} 	

  		if user = authenticate_app_user(params["token"])
  			data = params
			data.delete("token")

	  		if user.save_settings(data)
	  			response = { "success" => "Settings saved" }
	  		else
	  			response["error_server"] = stringify_error_messages user
	  		end
	  	else
	  		response = { "error" => unauthorized_user }
	  	end

  		respond_to do |format|
	    	puts "AC Save Settings response => #{response}"
	    	format.json { render json: response }
	    end			
	end

	protected

		def cross_origin_allow_header
			headers['Access-Control-Allow-Origin'] = "*"
			headers['Access-Control-Request-Method'] = '*'
		end

	   	def array_these_gifts(obj, send_fields, address_get=false, receiver=false, order_num=false)
	      gifts_ary = []
	      index = 1 
	      obj.each do |g|
	      	
		    gift_obj = g.serializable_hash only: send_fields

	        gift_obj.each_key do |key|
	          value = gift_obj[key]
	          gift_obj[key] = value.to_s
	        end

	      	gift_obj["shoppingCart"] = convert_shoppingCart_for_app(g.shoppingCart)

		        	# add other person photo url 
	        if receiver
	          if g.receiver
	            gift_obj["receiver_photo"]  = g.receiver.get_photo
	            gift_obj["receiver_name"] 	= g.receiver.username
	          	gift_obj["receiver_id"]	  	= g.receiver.id
	          else
	            puts "#Gift ID = #{g.id} -- SAVE FAIL No gift.receiver"
	          	gift_obj["receiver_photo"]  = ""
	          	if g.receiver_name
	          		gift_obj["receiver_name"] = g.receiver_name
	          	else
	          		gift_obj["receiver_name"] = "Unregistered"
	          	end
	          end
	        end
	        if !order_num
	        	# in MERCHANT_REPLY
		        gift_obj["giver_photo"]        = g.giver.get_photo
		        provider = g.provider 
		        gift_obj["provider_photo"]     = provider.get_image("photo")
		        gift_obj["provider_phone"]	   = provider.phone
		        gift_obj["city"]	   		   = provider.city
		        gift_obj["sales_tax"]		   = provider.sales_tax
		        	# add the full provider address
		        if address_get
		          gift_obj["provider_address"] = provider.complete_address
		        end
	    	end

	        gift_obj["gift_id"]  = g.id.to_s
	        gift_obj["time_ago"] = time_ago_in_words(g.created_at.to_time)
	      	
	        gift_obj["redeem_code"]	  = add_redeem_code(g)

	        gifts_ary << gift_obj
	      end
	      return gifts_ary
	    end

	
		def add_redeem_code(obj)
			if obj.status == "notified" 
				obj.redeem.redeem_code
			else
				"none"
			end
		end

		def serialize_objs_in_ary ary
			ary.map { |o| o.serialize }
		end

	    def convert_shoppingCart_for_app(shoppingCart)
	    	cart_ary = JSON.parse shoppingCart
	    	# puts "shopping cart = #{cart_ary}"
	    	new_shopping_cart = []
	    	if cart_ary[0].has_key? "menu_id"
		    	cart_ary.each do |item_hash|
		    		item_hash["item_id"]   = item_hash["menu_id"]
	        		item_hash["item_name"] = item_hash["name"]
	        		item_hash.delete("menu_id")
	        		item_hash.delete("name")
	        		new_shopping_cart << item_hash
	        		puts "AppC -convert_shoppingCart_for_app- new shopping cart = #{new_shopping_cart}"
		    	end
		    else
		    	new_shopping_cart = cart_ary
	    	end

	    	return new_shopping_cart
	    end

		def add_receiver_by_origin(origin, gift_obj, response)
			case origin
		    when 'd'
		      #drinkboard - data already received
		      response["origin"]     = "d"
		    when 'f'
		      # facebook - search users for facebook_id
		      if gift_obj["facebook_id"]
		        if receiver = User.find_by_facebook_id(gift_obj["facebook_id"])
		          gift_obj             = add_receiver_to_gift_obj(receiver, gift_obj)
		          response["origin"] = receiver_info_response(receiver)
		        else
		          gift_obj["status"]   = "incomplete"
		          response["origin"] = "NID"
		        end
		      else                   
		          gift_obj["status"]   = "incomplete"
		          response["error-receiver"] = "No facebook ID received"
		      end
		    when 't'
		      #twitter - search users for twitter handle
		      if gift_obj["twitter"]
		        if receiver = User.find_by_twitter(gift_obj["twitter"].to_s)
		          gift_obj             = add_receiver_to_gift_obj(receiver, gift_obj)
		          response["origin"] = receiver_info_response(receiver)
		        else                   
		          gift_obj["status"]   = "incomplete"
		          response["origin"] = "NID"
		        end
		      else
		        gift_obj["status"]     = "incomplete"
		        response["error-receiver"] = "No twitter info received"
		      end
		    when 'c'
		      # contacts - search users for phone
		      if gift_obj["receiver_phone"]
		        phone_received = gift_obj["receiver_phone"]
		        phone = extract_phone_digits(phone_received)
		        if receiver = User.find_by_phone(phone)
		          gift_obj             = add_receiver_to_gift_obj(receiver, gift_obj)
		          response["origin"] = receiver_info_response(receiver)
		        else
		          gift_obj["status"]   = "incomplete"
		          response["origin"] = "NID"
		        end
		      else
		          gift_obj["status"]   = "incomplete"
		          response["error-receiver"] = "No contact phone received"
		      end
		    when 'e'
		      # email - search users for phone
		      if gift_obj["receiver_email"]
		        if receiver = User.find_by_email(gift_obj["receiver_email"])
		          gift_obj             = add_receiver_to_gift_obj(receiver, gift_obj)
		          response["receiver"] = receiver_info_response(receiver)
		        else
		          gift_obj["status"]   = "incomplete"
		          response["origin"] = "NID"
		        end
		      else
		          gift_obj["status"]   = "incomplete"
		          response["error-receiver"] = "No contact email received"
		      end
		    else
		        #drinkboard - no origin sent
		        response["origin"]     = "d"
		    end
		end

		def extract_phone_digits(phone_raw)
			if phone_raw
				phone_match = phone_raw.match(VALID_PHONE_REGEX)
				phone       = phone_match[1] + phone_match[2] + phone_match[3]
			end
	    end
	    
	    def receiver_info_response(receiver)
	      	{ "receiver_id" => receiver.id.to_s, "receiver_name" => receiver.username, "receiver_phone" => receiver.phone }
	    end
	    
	    def add_receiver_to_gift_obj(receiver, gift_obj)
	      	gift_obj["receiver_id"]    = receiver.id
	      	gift_obj["receiver_name"]  = receiver.username
	      	gift_obj["receiver_phone"] = receiver.phone
	      	return gift_obj
	    end

 
end
