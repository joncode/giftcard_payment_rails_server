class AppController < JsonController
    include Email

 	def authenticate_app_user(token)
 		if user = User.find_by_remember_token(token)
 			user
 		else
 			false
 		end
	end

  	def shorten_url_for_provider_ary providers_array
  		providers_array.each do |prov|
  			short_photo_url = short_photo_url prov["photo"]
  			prov["photo"] 	= short_photo_url
  		end
  	end

  	def shorten_url_for_brand_ary brands_array
  		brands_array.each do |brand|
  			short_photo_url = short_photo_url brand["photo"]
  			brand["photo"] 	= short_photo_url
  		end
  	end

  	def short_photo_url photo_url
  		url_ary 		= photo_url.split('upload/')
  		shorten_url 	= url_ary[1]

  		identifier, tag = shorten_url.split('.')

  		new_photo_ary 	= ['d', identifier , 'j']
  		if photo_url.match 'htaaxtzcv'
  			new_photo_ary[0] = 'h'
  		end

  		if !tag.match('jpg')
  			new_photo_ary[2] = tag.match('png') ? 'p' : tag
  		end

  		new_photo_ary.join("|")
  	end

 	def update_user

 		response = {}
 		if user = authenticate_app_user(params["token"])
 		 			# user is authenticated
 		 	puts "App -Update_user- data = #{params["data"]}"
            updates =
                if params["data"].kind_of? String
                    JSON.parse params["data"]
                else
                    params["data"]
                end
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
	    	@app_response = "AppC #{response}"
	    	format.json { render json: response }
	    end
 	end

    def archive

        response = {}
        if user  = authenticate_app_user(params["token"])
            # user is authenticated
            give_gifts, rec_gifts  = Gift.get_archive(user)
            give_array             = array_these_gifts(give_gifts, BUY_REPLY, true, true)
            rec_array              = array_these_gifts(rec_gifts, GIFT_REPLY, true)
            logmsg                 = "#{give_array[0]} + #{rec_array[0]}"
            response = {"sent" => give_array, "used" => rec_array }
        else
            # user is not authenticated
            response["error"] = {"user" => "could not identity app user"}
            logmsg = "Error unauthorized user"
        end

        respond_to do |format|
            @app_response = logmsg
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
	    	@app_response = "AC badge = #{badge}"
	    	format.json { render json: response }
	    end
 	end

 	def menu

 		response = {}

 		if authenticate_public_info
 			provider_id  = params["data"]
 			response     = MenuString.get_menu_for_provider(provider_id.to_i)
 			logmsg 	     = response
 		else
 			response["error"] = database_error
 			logmsg 	     = response.to_s
 		end

	    respond_to do |format|
	    	# logger.debug response
	    	@app_response = "AC response => #{logmsg}"
	    	format.json { render json: response }
	    end
 	end

    def menu_v2

        response = {}

        if authenticate_public_info
            provider_id  = params["data"]
            response     = MenuString.get_menu_v2_for_provider(provider_id.to_i)
            logmsg       = response
        else
            response["error"] = database_error
            logmsg       = response.to_s
        end

        respond_to do |format|
            # logger.debug response
            @app_response = "AC response => #{logmsg}"
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
	      @app_response = "AC response[0] => #{logmsg}"
	      format.json { render json: gifts_array }
	    end
  	end

 	def orders
 			# send orders to the app for a provider
 		provider_id = params["provider"].to_i
 		if provider_id > 0
		    if user = authenticate_app_user(params["token"])
                    # this does not veriy that you are an employee
		    	provider 	= Provider.find(provider_id)
	    		gifts 		= Gift.get_history_provider(provider)
		    	gifts_array = array_these_gifts(gifts, MERCHANT_REPLY, false, true, true)
		  		logmsg 		= gifts_array[0]
		  	else
		  		gift_hash 	= {"error" => "user was not found in database"}
		  		gifts_array = gift_hash
		  		logmsg 		= gift_hash
		  	end
		else
			gift_hash 	= {"error" => database_error_general }
		  	gifts_array = gift_hash
		  	logmsg 		= gift_hash
		end
	    respond_to do |format|
	      # logger.debug gifts_array
	      @app_response = "AC response[0] => #{logmsg}"
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
	      	@app_response = "AppC #{response}"
	      	format.json { render json: response }
	    end
  	end

  	def user_activity

	    user  = User.find(params["user_id"].to_i)
	    if user
	    	gifts 		= Gift.get_user_activity(user)
	    	gifts_array = array_these_gifts(gifts, ADMIN_REPLY, true, true)
	  		logmsg 		= gifts_array[0]
	  	else
	  		gift_hash 	= {"error" => "user was not found in database"}
	  		gifts_array = gift_hash
	  		logmsg 		= gift_hash
	  	end
	    respond_to do |format|
            # logger.debug gifts_array
            @app_response = "AC response[0] => #{logmsg}"
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
            @app_response = "AC response[0] => #{logmsg}"
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
	    	@app_response = "AppC #{response}"
	    	format.json { render json: response }
	    end
  	end

 	def others_questions
  		# user  = User.find_by_remember_token(params["token"])

  		begin
  			other_user   = User.find(params["user_id"].to_i)
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
	      	@app_response = "AppC #{response}"
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
	      @app_response = "AppC response[0] => #{logmsg}"
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
	    	providers_array = providers.serialize_objs
	    	logmsg 			= providers_array[0]
	  	else
	  		providers_hash 	= {"error" => "user was not found in database"}
	  		providers_array = providers_hash
	  		logmsg 			= providers_hash
	  	end

  		respond_to do |format|
            # logger.debug providers_array
            @app_response = "AppC response[0] => #{logmsg}"
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
	    	providers_array = providers.serialize_objs
	    	providers_array = shorten_url_for_provider_ary providers_array
	    	logmsg 			= providers_array[0]
	  	else
	  		providers_hash 	= {"error" => "user was not found in database"}
	  		providers_array = providers_hash
	  		logmsg 			= providers_hash
	  	end

  		respond_to do |format|
            # logger.debug providers_array
            @app_response = "AppC response[0] => #{logmsg}"
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
	    	brands_array 	= brands.serialize_objs
	    	# brands_array  = shorten_url_for_brand_ary brands_array
	    	logmsg 			= brands_array[0]
	  	else
	  		brands_hash 	= {"error" => "user was not found in database"}
	  		brands_array 	= brands_hash
	  		logmsg 			= brands_hash
	  	end

  		respond_to do |format|
            # logger.debug providers_array
            @app_response = "AppC response[0] => #{logmsg}"
            format.json { render json: brands_array }
	    end
  	end

  	def brand_merchants
	    if  authenticate_public_info
	    	brand_id = params["data"].to_i
	    	begin
	    		brand 			= Brand.find brand_id
	    		providers_array = brand.providers.serialize_objs
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
	      @app_response = "AppC response[0] => #{logmsg}"
	      format.json { render json: providers_array }
	    end
  	end

	def drinkboard_users

		begin
			user = authenticate_app_user(params["token"])
			# @users = User.find(:all, :conditions => ["id != ?", @user.id])
			# providers = Provider.find(:all, :conditions => ["staff_id != ?", nil])
			if !params['city'] || params['city'] == 'all'
				users    = User.where(active: true).to_a
			else
				users    = User.where(active: true).find_all_by_city(params['city'])
			end
			user_array = users.serialize_objs
			logmsg 	   = user_array[0]
		rescue
			puts "ALERT - cannot find user from token"
			user_array = {"error" => "cannot find user from token"}
			logmsg 	   = user_array
		end


		respond_to do |format|
			# logger.debug user_array
			@app_response = "AppC response[0] => #{logmsg}"
			format.json { render json: user_array }
		end
	end

	def create_redeem_emps

    	message  = ""
    	response = {}
    	process  = false
    	gift_id  = params["data"].to_i

    	if gift_id == 0
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
			@app_response = "AppC #{response}"
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
	  				response["success"]      = redeem.redeem_code.to_s
	  			else
	  				response["error_server"] = database_error_redeem
	  			end
	  		rescue
	  			response["error_server"]     = database_error_redeem
	  		end
  		else
  			response["error"] = unauthorized_user
  		end

  		respond_to do |format|
  			@app_response = "AppC #{response}"
  			format.json { render json: response}
  		end
  	end

  	def create_order
  		response = {}
  		# receive {"token" => "<token>", "data" => "<gift_id>", "server_code" => <server_code> }
  		  			# authenticate user
  		if receiver = authenticate_app_user(params["token"])
  					# get gift from db
  			begin
	  			gift  = Gift.find params["data"].to_i
	  			order = Order.init_with_gift(gift, params["server_code"])
	  			if order.save
	  				response["success"] = { "order_number" => order.make_order_num,  "total" => gift.total, "server" => order.server_code }
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
  			@app_response = "AppC #{response}"
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
                if gift_obj["receiver_id"].nil?
                    add_receiver_object_to(gift_obj, response)
                else
                    # check that the receiver_id is active
                    if receiver = User.find(gift_obj["receiver_id"].to_i)
                        if receiver.active == false
                            response["error"] = 'User is no longer in the system , please gift to them with phone, email, facebook, or twitter'
                            gift_obj["receiver_id"] = nil
                            gift_obj["receiver_name"] = nil
                        end
                    end

                end
		        gift    = Gift.new(gift_obj)
                sc      = JSON.parse(params["shoppingCart"])
		        gift.make_gift_items(sc)
	  				# add the giver info to the gift object
	  			# if gift_obj["anon_id"]
			   #      gift.add_anonymous_giver(giver.id)
			   #  else
			   #    	gift.add_giver(giver)
			   #  end
	  			puts "Here is GIFT #{gift.inspect}"
	  			if gift.save
	  				sale = gift.charge_card
			        if sale.resp_code == 1
			        	response["success"]       = { "Gift_id" => gift.id }
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
		gift_id 	= params["gift_id"].to_i
		employee_id = params["employee_id"].to_i

		if gift_id == 0 || employee_id == 0
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
			@app_response = "AppC #{response}"
			format.json { render json: response }
		end
	end

	def delete_card

		# message = ""
		response = {}

		if user = authenticate_app_user(params["token"])
			cCard = Card.find(params["data"].to_i)
			# if cCard.user_id == user.id
				if cCard.destroy
					response["delete"] = "#{cCard.id}"
				else
					response["error_server"] = "#{cCard.nickname} #{cCard.id} could not be deleted"
				end
			# end
		else
			response["error"] = "Couldn't identify app user. "
		end

		respond_to do |format|
			@app_response = "AppC #{response}"
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
			@app_response = "AppC #{response}"
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
      		if card_data["user_id"].nil?
      			card_data["user_id"] = user.id
      		end
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
					response["add"]      = cCard.id
					puts "here is the saved new ccard = #{cCard.inspect}"
				else
					response["error_server"] = stringify_error_messages cCard
				end
			#end
			@app_response = "AppC #{response}"
			puts message
			format.json { render json: response }
		end

	end

	def reset_password

		if params[:email]
			user = User.find_by_email(params[:email])
			if user
				user.update_reset_token
				# Resque.enqueue(EmailJob, 'reset_password', user.id, {})
                send_reset_password_email(user)
				response = {"success" => "Email is Sent , check your inbox"}
			else
				response = {"error" => "We do not have record of that email"}
			end
		else
			response = {"error" => "no email sent"}
		end

		respond_to do |format|
			@app_response = "AppC #{response}"
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
	    	@app_response = "AppC #{response}"
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
	    	@app_response = "AppC #{response}"
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
	    	@app_response = "AppC #{response}"
	    	format.json { render json: response }
	    end
	end

protected

    def add_receiver_object_to gift_obj, response

        unique_ids = [gift_obj["receiver_phone"], gift_obj["facebook_id"], gift_obj["receiver_email"], gift_obj["twitter"] ].compact
        # loop thru the ones with data
        unique_ids.each do |unique_id|
            if find_user(unique_id, gift_obj, response)
                # stop when you find a user
                break
            end
        end
    end

    def find_user unique_id, gift_obj, response
        if social_data = UserSocial.find_by_identifier(unique_id)
            receiver             = social_data.user
            gift_obj             = add_receiver_to_gift_obj(receiver, gift_obj)
            response["receiver"] = receiver_info_response(receiver)
            response["origin"]   = social_data.type_of
            return true
        else
            gift_obj["status"]   = "incomplete"
            response["origin"]   = "NID"
            return false
        end
    end

    def receiver_info_response receiver
      	{ "receiver_id" => receiver.id.to_s, "receiver_name" => receiver.username, "receiver_phone" => receiver.phone }
    end

    def add_receiver_to_gift_obj receiver, gift_obj
      	gift_obj["receiver_id"]    = receiver.id
      	gift_obj["receiver_name"]  = receiver.username
      	gift_obj["receiver_phone"] = receiver.phone
        gift_obj["receiver_email"] = receiver.email
      	return gift_obj
    end

end
