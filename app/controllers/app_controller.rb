class AppController < ApplicationController
	include ActionView::Helpers::DateHelper
	# include ActiveMerchant::Billing::CreditCardMethods
	# include ActiveMerchant::Billing::CreditCardMethods::ClassMethods
	
	GIFT_REPLY = ["giver_id", "giver_name", "item_id", "item_name", "provider_id", "provider_name", "category", "message", "created_at", "status"]
    ACTIVITY_REPLY = [ "giver_id", "giver_name","receiver_id", "receiver_name", "item_id", "item_name", "provider_id", "provider_name", "category", "message", "created_at", "status"] 

 	USER_REPLY = ["first_name", "last_name", "email", "phone", "facebook_id"]
 	PROVIDER_REPLY = ["name", "photo", "box", "logo", "portrait", "sales_tax"]

 	def menu
 		puts "\nMenu App"
 		puts "#{params}"

 		user = User.find_by_remember_token(params["token"])
 		provider_id  = params["data"]

 		if user
 			menu_string = MenuString.get_menu_for_provider(provider_id.to_i)
 		else
 			menu_string = {"error" => "user was not found in database"}
 			menu_string.to_json
 		end
	    respond_to do |format|
	      logger.debug menu_string
	      format.json { render text: menu_string }
	    end
 	end

 	def gifts
	    puts "\nGifts"
	    puts "#{params}"

	    user  = User.find_by_remember_token(params["token"])
	    if user
	    	gifts 		= Gift.get_gifts(user)
	    	gifts_array = array_these_gifts(gifts, GIFT_REPLY, true)
	  	else
	  		gift_hash 	= {"error" => "user was not found in database"}
	  		gifts_array = gift_hash
	  	end
	    respond_to do |format|
	      logger.debug gifts_array
	      format.json { render text: gifts_array.to_json }
	    end
  	end

  	 def user_activity
	    puts "\nUser Activity"
	    puts "#{params}"

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
	      format.json { render text: gifts_array.to_json }
	    end
  	end

  	 def past_gifts
	    puts "\nGifts"
	    puts "#{params}"

	    user  = User.find_by_remember_token(params["token"])
	    if user
	    	gifts 		= Gift.get_past_gifts(user)
	    	gifts_array = array_these_gifts(gifts, GIFT_REPLY, true)
	  	else
	  		gift_hash 	= {"error" => "user was not found in database"}
	  		gifts_array = gift_hash
	  	end
	    respond_to do |format|
	      logger.debug gifts_array
	      format.json { render text: gifts_array.to_json }
	    end
  	end

  	def questions
  		puts "\nQuestions"
  		puts "HERE ARE THE PARAMS #{params}"
  		user  = User.find_by_remember_token(params["token"])
  		
  		  	# save filled out answers to db
  		if params["answers"] && user
        puts "ANSWERS #{params['answers']}"
  			answered_questions = JSON.parse params["answers"]
  			Answer.save_these(answered_questions, user)
  		end

  		if user
	  			# get new pack of questions
			   begin
	  			  questions_array = Question.get_questions_with_answers(user)
	  		 rescue
	  			  questions_array = ["error", "could not get questions"]
	  		 end
	  	else
	  		 questions_array = ["error", "could not find user in db"]
	  	end
  		respond_to do |format|
	      puts questions_array
	      format.json { render text: questions_array.to_json }
	    end
  	end

 	def others_questions
  		puts "\nOthers Questions"
  		puts "HERE ARE THE PARAMS #{params}"
  		user  = User.find_by_remember_token(params["token"])
  		
  		other_user = User.find(params["user_id"])

  		if  other_user
	  			# get new pack of questions
			begin
	  			questions_array = Question.get_questions_with_answers(other_user)
	  		rescue
	  			questions_array = ["error", "could not get questions"]
	  		end
	  	else
	  		questions_array = ["error", "could not find other user in db"]
	  	end
  		respond_to do |format|
	      	puts questions_array
	      	format.json { render text: questions_array.to_json }
	    end
  	end
  	def transactions
  		puts "\nTransactions"
  		puts "#{params}"
  		user  = User.find_by_remember_token(params["token"])

  		if user
  			transaction_array = Gift.transactions(user)
	  	else
	  		transaction_array = ["error", "could not find user in db"]
	  	end
  		respond_to do |format|
	      logger.debug transaction_array
	      format.json { render text: transaction_array.to_json }
	    end
  	end

  	def providers
  		puts "\nProviders"
  		puts "#{params}"

		user  = User.find_by_remember_token(params["token"])
	    if user
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
	      format.json { render text: providers_array.to_json }
	    end
  	end

	def drinkboard_users
		puts "\nDrinkboard Users"
		puts "#{params}"

		begin
			user = User.find_by_remember_token(params["token"])
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
			format.json { render text: user_array.to_json }
		end
	end

	def create_redeem
    	puts "\nCreate Redeem (App Controller) no server code"
    	puts "#{params}"

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
      		receiver = User.find_by_remember_token(params["token"])
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
			puts response
			format.json { render text: response.to_json}
		end
  	end

	def create_order
		puts "\nCreate Order"
		puts "#{params}"

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
			user 	 = User.find_by_remember_token(params["token"])
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
			puts response
			format.json { render text: response.to_json }
		end
	end  

	def get_cards
		puts "\nGet Cards"
		puts "#{params}"

		message   = ""
		response  = {} 
		begin
      		user = User.find_by_remember_token(params["token"])
      		display_cards = Card.get_cards user
      		if display_cards.empty?
      			response["error"] = "User has no cards on file"
      		else
      			response["success"] = display_cards
      		end
    	rescue
      		message += "Couldn't identify app user. "
    	end

    	respond_to do |format|
			puts response
			puts message
			format.json { render text: response.to_json }
		end
	end

	def add_card
		puts "\nAdd Card"
		puts "#{params}"

		message   = "" 
		response  = {} 
		# begin
      		user = User.find_by_remember_token(params["token"])
      		puts user
      		card_data = params["data"]
      		puts "params data = #{params['data']}"
      		puts "card_data = #{card_data}"
      		ccard = Card.create_card_from_hash card_data
      		puts "the new card object is = #{ccard}"
    	# rescue
     #  		message += "Couldn't identify app user. "
    	# end

    	respond_to do |format|
			#if message.empty?
				if ccard.save
					response["success"]      = "Card added"
				else
					response["error_server"] = ccard.errors.messages
				end
			#end
			puts response
			puts message
			format.json { render text: response.to_json }
		end
		
	end

	protected

	   	def array_these_gifts(obj, send_fields, address_get=false, receiver=false)
	      gifts_ary = []
	      index = 1 
	      obj.each do |g|
	      
	        ### >>>>>>>    item_name pluralizer
	        # g.item_name = g.item_name.pluralize if g.quantity > 1
	        ###  7/27 6:45 UTC
	        
	        if g.created_at 
	          time = g.created_at.to_time
	        else
	          time = g.updated_at.to_time
	        end
	        time_string = time_ago_in_words(time)
	      	
		    gift_obj = g.serializable_hash only: send_fields

	        gift_obj.each_key do |key|
	          value = gift_obj[key]
	          gift_obj[key] = value.to_s
	        end

	        if !g.shoppingCart 
	      		# make shopping cart array with item inside as Hash
	      		# using item_id, item_name, category, quantity, price
	      		menu_item = {"id" => g.item_id.to_s, "item_name" => g.item_name, "quantity" => 4 , "price" => g.price.to_s, "category" => g.category.to_s, "section" => BEVERAGE_CATEGORIES[g.category] }
	      		menu_item_array = [menu_item]

	      		# shoppingCart = menu_item_array.to_json
	      		# g.update_attribute(:shoppingCart, shoppingCart)
	      		gift_obj["shoppingCart"] = menu_item_array
	      	else
	      		# turn shoppingCart into an array with hashes

	      		gift_obj["shoppingCart"] = convert_shoppingCart_for_app g.shoppingCart
	      	end

		        # add other person photo url 
	        if receiver
	          if g.receiver
	            gift_obj["receiver_photo"]  = g.receiver.get_photo
	            gift_obj["giver_photo"]     = g.giver.get_photo
	          else
	            puts "#Gift ID = #{g.id} -- SAVE FAIL No gift.receiver"
	          	gift_obj["receiver_photo"]  = ""
	          	gift_obj["giver_photo"]     = g.giver.get_photo
	          	if g.receiver_name
	          		gift_obj["receiver_name"] = g.receiver_name
	          	else
	          		gift_obj["receiver_name"] = "Unregistered"
	          	end
	          end
	        else
	          gift_obj["giver_photo"]       = g.giver.get_photo
	        end

	        provider = g.provider 
	        gift_obj["provider_photo"]     = provider.get_photo
	        # add the full provider address
	        if address_get
	          gift_obj["provider_address"] = provider.complete_address
	        end

	        gift_obj["gift_id"]  = g.id.to_s
	        gift_obj["time_ago"] = time_string
	      	
	        ### >>>>>>>    this is not stored in gift object
	        gift_obj["redeem_code"] = add_redeem_code(g)
	        ###  07-27 9:08 UTC
	            
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

	    def convert_shoppingCart_for_app shoppingCart
	    	cart_ary = JSON.parse shoppingCart
	    	puts "shopping cart = #{shoppingCart}"
	    	new_shopping_cart = []
	    	if cart_ary[0].has_key? "menu_id"
		    	cart_ary.each do |item_hash|
		    		item_hash["item_id"] = item_hash["menu_id"]
	        		item_hash["item_name"] = item_hash["name"]
	        		item_hash.delete("menu_id")
	        		item_hash.delete("name")
	        		new_shopping_cart << item_hash
		    	end
		    else
		    	new_shopping_cart = cart_ary
	    	end

	    	return new_shopping_cart
	    end
 
end
