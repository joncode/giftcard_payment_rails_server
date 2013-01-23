class AppController < ApplicationController
	include ActionView::Helpers::DateHelper
	skip_before_filter :verify_authenticity_token

	UPDATE_REPLY  = ["id", "first_name", "last_name" , "address" , "city" , "state" , "zip", "email", "phone"]  
 	USER_REPLY = ["first_name", "last_name", "email", "phone", "facebook_id"]	
	GIFT_REPLY = ["giver_id", "giver_name", "provider_id", "provider_name", "message", "status"]
    ACTIVITY_REPLY = GIFT_REPLY + [ "receiver_id", "receiver_name"] 
 	PROVIDER_REPLY = ["name",  "box", "logo", "portrait", "sales_tax", "phone"]

 	def update_user
  		puts "\nUpdate User"
 		puts "request = #{params}"	
 		if user = authenticate_app_user(params["token"])
 		 			# user is authenticated
 		 	puts "App -Update_user- data = #{params["data"]}"
 		 	updates = JSON.parse params["data"]
 		 	#updates = params["data"]
 		 	puts "App -Update_user- data = #{updates}"
 		else
 			# user is not authenticated
 			response["error"] = {"user" => "could not identity app user"}
 		end

 		respond_to do |format|
 			if user.update_attributes(updates)
	          response["success"]      = user.to_json only: UPDATE_REPLY
	        else
	          response["error_server"] = "Unable to process user updates to database." 
	        end
	    	puts "response => #{response}"
	    	format.json { render json: response }
	    end	
 	end

 	def relays
 		puts "\nRelays to APP"
 		puts "request = #{params}"
 		response = {}
 		    # get app version from data hash
		    # compare app version from version -- in db??
		    # get photo url from data hash 
		    # compare photo version with proper photo for user 
		    # if either are not same 
		    # return "update_photo" or "update_app" or both
		    # put new data into each value for key
		    # if both are the same 
		    # return "success"
		    # send current is_public status 

 		if user = authenticate_app_user(params["token"])
 			# user is authenticated
 			relays = Relay.where("receiver_id = :id AND status != :msg", :id => user.id, :msg => "redeemed")
 			badge  = relays.size
 			gift_array = []
 			if badge > 0
	 			relays.each do |relay|
	 				gift_array << relay.gift
	 			end
	 			gift_array_to_app = array_these_gifts(gift_array, GIFT_REPLY, true)
	 			response["success"] = { "badge" => badge, "gifts" => gift_array_to_app }
	 		else
	 			response["success"] = { "badge" => 0 }
	 		end
 		else
 			# user is not authenticated
 			response["error"] = {"user" => "could not identity app user"}
 		end
 		respond_to do |format|
	    	logger.debug response
	    	puts "response => badge = #{badge}"
	    	format.json { render json: response }
	    end
 	end

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

 	def menu
 		puts "\nMenu App"
 		puts "request = #{params}"
 		response = {}
	
 		if authenticate_public_info
 			provider_id  = params["data"]
 			response = []
 			response = MenuString.get_menu_for_provider(provider_id.to_i)
 		else
 			response["error"] = "user was not found in database"
 		end
	    
	    respond_to do |format|
	    	logger.debug response
	    	puts "response => #{response}"
	    	format.json { render json: response }
	    end
 	end

 	def gifts
	    puts "\nGifts"
	    puts "request = #{params}"

	    if user = authenticate_app_user(params["token"])
	    	gifts 		= Gift.get_gifts(user)
	    	gifts_array = array_these_gifts(gifts, GIFT_REPLY, true)
	  	else
	  		gift_hash 	= {"error" => "user was not found in database"}
	  		gifts_array = gift_hash
	  	end
	    respond_to do |format|
	      logger.debug gifts_array
	      puts "response => #{response}"
	      format.json { render json: gifts_array }
	    end
  	end

  	def user_activity
	    puts "\nUser Activity"
	    puts "request = #{params}"

	    user  = User.find(params["user_id"])
	    if user 
	    	gifts 		= Gift.get_user_activity(user)
	    	gifts_array = array_these_gifts(gifts, ACTIVITY_REPLY, true, true)
	  	else
	  		gift_hash 	= {"error" => "user was not found in database"}
	  		gifts_array = gift_hash
	  	end
	    respond_to do |format|
	      logger.debug gifts_array
	      puts "response[0] => #{gifts_array[0]}"
	      format.json { render json: gifts_array }
	    end
  	end

  	def past_gifts
	    puts "\nGifts"
	    puts "request = #{params}"

	    if user = authenticate_app_user(params["token"])
	    	gifts 		= Gift.get_past_gifts(user)
	    	gifts_array = array_these_gifts(gifts, GIFT_REPLY, true)
	  	else
	  		gift_hash 	= {"error" => "user was not found in database"}
	  		gifts_array = gift_hash
	  	end
	    respond_to do |format|
	      logger.debug gifts_array
	      puts "response[0] => #{gifts_array[0]}"
	      format.json { render json: gifts_array }
	    end
  	end

  	def questions
  		puts "\nQuestions"
  		puts "request = #{params}"
  		  		
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
	    	puts "response => #{response}"
	    	format.json { render json: response }
	    end
  	end

 	def others_questions
  		puts "\nOthers Questions"
  		puts "request = #{params}"
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
	      	puts "response => #{response}"
	      	format.json { render json: response }
	    end
  	end

  	def transactions
  		puts "\nTransactions"
  		puts "request = #{params}"

  		if user = authenticate_app_user(params["token"])
  			transaction_array = Gift.transactions(user)
	  	else
	  		transaction_array = ["error", "could not find user in db"]
	  	end
  		respond_to do |format|
	      logger.debug transaction_array
	      puts "response[0] => #{transaction_array[0]}"
	      format.json { render json: transaction_array }
	    end
  	end

  	def providers
  		puts "\nProviders"
  		puts "request = #{params}"

	    if authenticate_public_info
	    	if  !params["city"] || params["city"] == "all"
	    		providers = Provider.all
	    	else
	    		providers = Provider.where(city: params["city"])
	    	end
	    	providers_array = array_these_providers(providers, PROVIDER_REPLY)
	  	else
	  		providers_hash 	= {"error" => "user was not found in database"}
	  		providers_array = providers_hash
	  	end

  		respond_to do |format|
	      logger.debug providers_array
	      puts "response[0] => #{providers_array[0]}"
	      format.json { render json: providers_array }
	    end
  	end

	def drinkboard_users
		puts "\nDrinkboard Users"
		puts "request = #{params}"

		begin
			user = authenticate_app_user(params["token"])
			# @users = User.find(:all, :conditions => ["id != ?", @user.id])
			# providers = Provider.find(:all, :conditions => ["staff_id != ?", nil])
			if !params['city'] || params['city'] == 'all'
				users    = User.all
			else
				users    = User.find_by_city(params['city'])
			end 
			user_array = array_these_users(users, USER_REPLY)
		rescue 
			puts "ALERT - cannot find user from token"
			user_array = {"error" => "cannot find user from token"}
		end


		respond_to do |format|
			logger.debug user_array
			puts "response[0] => #{user_array[0]}"
			format.json { render json: user_array }
		end
	end

	def create_redeem
    	puts "\nCreate Redeem (App Controller) no server code"
    	puts "request = #{params}"

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
			puts "response => #{response}"
			format.json { render json: response }
		end
  	end

	def create_order
		puts "\nCreate Order"
		puts "request = #{params}"

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
				response["error_server"] = " Order not processed - database error"
			end
			puts "response => #{response}"
			format.json { render json: response }
		end
	end 

	def delete_card
	 	puts "\nDelete Card"
		puts "request = #{params}"

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
			puts "response => #{response}"
			format.json { render json: response }
		end
	end 

	def get_cards
		puts "\nGet Cards"
		puts "request = #{params}"

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
			puts "response => #{response}"
			puts message
			format.json { render json: response }
		end
	end

	def add_card
		puts "\nAdd Card"
		puts "request = #{params}"

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
					response["error_server"] = cCard.errors.messages
				end
			#end
			puts "response => #{response}"
			puts message
			format.json { render json: response }
		end
		
	end

	protected

	   	def array_these_gifts(obj, send_fields, address_get=false, receiver=false)
	      gifts_ary = []
	      index = 1 
	      obj.each do |g|
	      	
		    gift_obj = g.serializable_hash only: send_fields

	        gift_obj.each_key do |key|
	          value = gift_obj[key]
	          gift_obj[key] = value.to_s
	        end

	        if !g.shoppingCart 
	      			# make shopping cart array with item inside as Hash
	      			# using item_id, item_name, category, quantity, price
	      		menu_item = {"id" => g.item_id.to_s, "item_name" => g.item_name, "quantity" => 4 , "price" => g.price.to_s }
	      		if g.category
	      			menu_item["category"] = g.category.to_s
	      			menu_item["section"] = BEVERAGE_CATEGORIES[g.category.to_i] 
	      		end
	      		menu_item_array = [menu_item]

	      			# shoppingCart = menu_item_array.to_json
	      			# g.update_attribute(:shoppingCart, shoppingCart)
	      		gift_obj["shoppingCart"] = menu_item_array
	      	else
	      			# turn shoppingCart into an array with hashes
	      		gift_obj["shoppingCart"] = convert_shoppingCart_for_app(g.shoppingCart)
	      	end

		        	# add other person photo url 
	        if receiver
	          if g.receiver
	            gift_obj["receiver_photo"]  = g.receiver.get_photo
	            	#gift_obj["giver_photo"]     = g.giver.get_photo
	          else
	            puts "#Gift ID = #{g.id} -- SAVE FAIL No gift.receiver"
	          	gift_obj["receiver_photo"]  = ""
	          		#gift_obj["giver_photo"]     = g.giver.get_photo
	          	if g.receiver_name
	          		gift_obj["receiver_name"] = g.receiver_name
	          	else
	          		gift_obj["receiver_name"] = "Unregistered"
	          	end
	          end
	        else
	          	#gift_obj["giver_photo"]       = g.giver.get_photo
	        end

	        gift_obj["giver_photo"]        = g.giver.get_photo
	        provider = g.provider 
	        gift_obj["provider_photo"]     = provider.get_image("photo")
	        gift_obj["provider_phone"]	   = provider.phone
	        gift_obj["provider_city"]	   = provider.city
	        	# add the full provider address
	        if address_get
	          gift_obj["provider_address"] = provider.complete_address
	        end

	        gift_obj["gift_id"]  = g.id.to_s
	        gift_obj["time_ago"] = time_ago_in_words(g.created_at.to_time)
	      	
	        gift_obj["redeem_code"] = add_redeem_code(g)
	            
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

		def array_these_providers(obj, send_fields)
			providers_array = []
			obj.each do |p|
				prov_obj = p.serializable_hash only: send_fields
				prov_obj.each_key do |key|
					value= prov_obj[key]
					prov_obj[key] = value.to_s
				end
				prov_obj["full_address"] = p.full_address
				prov_obj["provider_id"]  = p.id.to_s
				prov_obj["photo"] = p.get_image("photo")
				providers_array << prov_obj
			end
			return providers_array
		end

	    def array_these_users(obj, send_fields)
			users_array = []
			obj.each do |u|
				user_obj = u.serializable_hash only: send_fields
				user_obj.each_key do |key|
				  value = user_obj[key]
				  user_obj[key] = value.to_s
				end
				user_obj["photo"] 	= u.get_photo
				user_obj["user_id"] = u.id.to_s 
				users_array << user_obj
			end
			return users_array
	    end

	    def convert_shoppingCart_for_app(shoppingCart)
	    	cart_ary = JSON.parse shoppingCart
	    	# puts "shopping cart = #{cart_ary}"
	    	new_shopping_cart = []
	    	if cart_ary[0].has_key? "menu_id"
		    	cart_ary.each do |item_hash|
		    		item_hash["item_id"] = item_hash["menu_id"]
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
 
end
