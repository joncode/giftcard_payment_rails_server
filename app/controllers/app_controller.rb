class AppController < ApplicationController
	include ActionView::Helpers::DateHelper
	GIFT_REPLY = ["giver_id", "giver_name", "item_id", "item_name", "provider_id", "provider_name", "category", "quantity", "message", "created_at", "status"]
 	USER_REPLY = ["first_name", "last_name", "email", "phone", "facebook_id"]
 	PROVIDER_REPLY = ["name", "photo", "box", "logo", "portrait", "sales_tax"]
 	ACTIVITY_REPLY     = ["receiver_id", "receiver_name", "item_id", "item_name", "provider_id", "provider_name", "category", "quantity", "message", "created_at", "status", "giver_id", "giver_name"] 

 	def menu
 		puts "Menu App"
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
	    puts "Gifts"
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
	    puts "User Activity"
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
	    puts "Gifts"
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
  		puts "Questions"
  		puts "#{params}"
  		user  = User.find_by_remember_token(params["token"])
  		
  		  	# save filled out answers to db
  		if params["answers"]
  			answers = JSON.parse params["answers"]
  			Answer.save_these(answers)
  		end

  		if user
	  			# get new pack of questions
			begin
	  			questions_array = Question.get_six_new_questions(user)
	  		rescue
	  			questions_array = ["error", "could not get questions"]
	  		end
	  	else
	  		questions_array = ["error", "could not find user in db"]
	  	end
  		respond_to do |format|
	      logger.debug questions_array
	      format.json { render text: questions_array.to_json }
	    end
  	end

  	def transactions
  		puts "Questions"
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
  		puts "Providers"
  		puts "#{params}"

		user  = User.find_by_remember_token(params["token"])
	    if user
	    	providers = Provider.all
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
		puts "Drinkboard Users"
		puts "#{params}"

		begin
			user = User.find_by_remember_token(params["token"])
			# @users = User.find(:all, :conditions => ["id != ?", @user.id])
			# providers = Provider.find(:all, :conditions => ["staff_id != ?", nil])
			users    = User.all   
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
    	puts "Create Redeem (App Controller) no server code"
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

		respond_to do |format|
			if process
				response = redeem.gift.provider.employees_to_app
			else
				message += " Gift unable to process to database. Please retry later."
				response["error_server"] = message 
			end
			puts response
			format.json { render text: response.to_json}
		end
  	end

	def create_order
		puts "Create Order"
		puts "#{params}"

		message   = ""
		response  = {} 
		gift_id 	= params["gift_id"].to_i
		employee_id = params["employee_id"].to_i

		if gift_id.nil? || employee_id.nil? 
			message = "Data not received correctly. "
			order   = Order.new
		else
			order   = Order.new(gift_id: gift_id, employee_id: employee_id)
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
	        
		        # add other person photo url 
	        if receiver
	          if g.receiver
	            gift_obj["receiver_photo"]  = g.receiver.get_photo
	          else
	            puts "#Gift ID = #{g.id} -- SAVE FAIL No gift.receiver"
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
 
end
