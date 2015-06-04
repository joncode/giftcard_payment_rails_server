class AppController < JsonController
    include Email
    include Photo
    include CimProfile

    before_action :authenticate_services, only: [:create_gift]

 	def authenticate_app_user(token)
 		if user = User.app_authenticate(token)
 			user
 		else
 			false
 		end
	end

 	def update_user
 		@app_response = {}
        params["data"] = if params["data"].kind_of? String
                    begin
                        JSON.parse params["data"]
                    rescue
                        nil
                    end
                else
                    params["data"]
                end
        unless params["data"].kind_of?(Hash)
            @app_response["error"] = "App needs to be reset. Please log out and log back in."
        end
        params["data"]["api_v1"] = true if params["data"].present?
        if (user = authenticate_app_user(params["token"])) && (@app_response["error"].nil?)

            if user.update_attributes(user_params)
                @app_response["success"]      = user.serializable_hash only: UPDATE_REPLY
            else
                @app_response["error_server"] = stringify_error_messages user
            end
 		else
 			@app_response["error"] = "App needs to be reset. Please log out and log back in."
 		end

        respond
 	end

    def archive

        response = {}
        if user  = authenticate_app_user(params["token"])
            # user is authenticated
            give_gifts, rec_gifts  = Gift.get_archive(user)
            give_array             = array_these_gifts(give_gifts, BUY_REPLY, true, true)
            rec_array              = array_these_gifts(rec_gifts, GIFT_REPLY, true)
            logmsg                 = "\n#{give_array[0]} \n #{rec_array[0]}\n"
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
            # @app_response = "AC response => #{logmsg}"
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

	  		if params["answers"]
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
  		# user  = User.find_by(remember_token: params["token"])

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
         # scoped providers route
	    if authenticate_public_info
	    	if  !params["city"] || params["city"] == "all" || params["city"] == "Near Me"
	    		providers = Provider.all
	    	elsif params["city"].to_i == 0
	    		providers = Provider.where(region_id: region_id_from_name(params["city"]))
	    	else
	    		providers = Provider.where(region_id: params["city"])
	    	end
	    	providers_array = providers.serialize_objs
	    	logmsg 			= providers_array[0]
	  	else
	  		providers_hash 	= {"error" => "No merchants for this city were found in database"}
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

        users    = User.where(active: true).to_a

		user_array = users.serialize_objs
		logmsg 	   = user_array[0]

		respond_to do |format|
			# logger.debug user_array
			@app_response = "AppC response[0] => #{logmsg}"
			format.json { render json: user_array }
		end
	end

  	def create_redeem
  		response = {}
  		# receive {"token" => "<token>", "data" => "<gift_id>" }
  					# authenticate user
  		if receiver = authenticate_app_user(params["token"])
  					# get gift from db
  			begin
                gift   = receiver.received.where(id: params["data"].to_i).first
                if gift
			        if gift.notifiable?
			            gift.notify
			            Relay.send_push_thank_you gift
		  				response["success"]      = gift.token.to_s
		  			else
		  				response["error_server"] = database_error_redeem
		  			end
		  		else
		  			response["error_server"] = "Gift not found"
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
  		if receiver = authenticate_app_user(params["token"])
  			begin
                gift   = receiver.received.where(id: params["data"].to_i).first
		        if gift
		            if gift.status == 'notified'
		                if true # gift.token == request_params["token"]
		                    gift.redeem_gift(params["server_code"].to_s)
		                    response["success"]      =  { "order_number" => gift.token,  "total" => gift.value, "server" => gift.server }
		                else
		                    response["error_server"] =  "Token is incorrect for gift #{params[:id]}"
		                end
		            else
		                fail_message = if gift.status == 'redeemed'
		                    "Gift #{gift.token} has already been redeemed"
		                else
		                    "Gift #{gift.id} cannot be redeemed"
		                end
		                response["error_server"] =  {"Data Transfer Error"=> fail_message }
		            end
		        else
		        	response["error_server"] = {"Data Transfer Error"=>"Please Reload Gift Center"}
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

        gift_hsh = gift_params
        if promotional_gift_params? gift_hsh
            gift_response = "You cannot gift to the #{gift_hsh["receiver_name"]} account"
        else
            gift_hsh["shoppingCart"] = params["shoppingCart"]
            gift_hsh["value"] = gift_hsh["total"]
            gift_hsh["giver"] = @current_user
            gift_hsh.delete("total")

            gift_response = GiftSale.create(gift_hsh)
        end

        if gift_response.kind_of?(Gift)
            if gift_response.id
                response['success'] =  { "Gift_id" => gift_response.id }
            else
                response['error_server'] = gift_response.errors.messages

            end
        else
            response["error"] = gift_response

        end

        respond_to do |format|
            @app_response = "AppC #{response}"
            format.json { render json: response}
        end
    end

	def create_order_emp
		respond_to do |format|

			response["error_server"] = "Please Update your app"
			puts "\n\n\n\n OLD APP ALERT ~!!!~ \n\n\n\n"
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
				if destroy_card(cCard, user)   # cim_profile concern
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
            response["success"] = Card.get_cards(user)
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
			user = User.find_by(email: params[:email])
			if user
				user.update_reset_token
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

private

    def promotional_gift_params? params_hsh
        if params_hsh["receiver_id"].nil?
            false
        else
            if params_hsh["receiver_name"].match(" Staff")
                begin
                    user = User.find(params_hsh["receiver_id"])
                    if user.last_name == "Staff"
                        false
                    else
                        true
                    end
                rescue
                    true
                end
            else
                false
            end
        end
    end

    def user_params
    	params.require(:data).permit(:first_name, :last_name,  :phone, :email, :birthday, :sex, :zip, :facebook_id, :twitter, :api_v1)
    end

    def gift_params
        if params.require(:gift).kind_of?(String)
            pg = JSON.parse(params.require(:gift))
        else
            params.require(:gift).permit(:message, :giver_id,:giver_name,:value,:service,:receiver_id,:receiver_email, :receiver_phone,:twitter, :facebook_id, :receiver_name, :provider_name, :provider_id,:credit_card, :total, :api_v1)
        end
    end

    def region_id_from_name name
        region_hash = CITY_LIST.select { |region_h| region_h["name"] == name }
        region_hash[0]["region_id"].to_i
    end

end
