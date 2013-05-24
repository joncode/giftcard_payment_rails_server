class IphoneController < AppController

	LOGIN_REPLY     = ["id", "first_name", "last_name" , "address" , "city" , "state" , "zip", "birthday", "sex", "remember_token", "email", "phone", "facebook_id", "twitter"]
	GIFT_REPLY      = ["giver_id", "giver_name", "item_id", "item_name", "provider_id", "provider_name", "category",  "message", "created_at", "status", "id"]
	BUY_REPLY       = ["tip","total", "receiver_id", "receiver_name", "item_id", "item_name", "provider_id", "provider_name", "category",  "message", "created_at", "status", "id"]
	BOARD_REPLY     = ["receiver_id", "receiver_name", "item_id", "item_name", "provider_id", "provider_name", "category",  "message", "created_at", "status", "giver_id", "giver_name", "id"]
	PROVIDER_REPLY  = ["receiver_id", "receiver_name", "item_id", "item_name", "provider_id", "provider_name", "category",  "status", "redeem_id", "redeem_code", "created_at", "giver_id", "price", "total",  "giver_name", "id"]
	MERCHANT_REPLY  = ["receiver_id", "receiver_name","giver_name", "item_id", "item_name","category", "price", "total", "tax" , "tip", "message", "created_at", "id", "redeem_id", "redeem_code"]
	COMPLETED_REPLY = ["receiver_id", "receiver_name","giver_name", "item_id", "item_name","category", "price", "total", "tax" , "tip", "message", "updated_at", "id", "redeem_id", "redeem_code"]

	def create_account

		data     = params["data"]
		pn_token = params["pn_token"] || nil

		if data.nil?
			message = "Data not received correctly. "
		else
			new_user = create_user_object(data)
			puts "HERE IS NEW USER DATA #{new_user.inspect}"
			message = ""
		end

		respond_to do |format|
			if !data.nil? && new_user.save
				new_user.pn_token = pn_token if pn_token
				user_to_app = {"user_id" => new_user.id, "token" => new_user.remember_token}
				response = { "success" => user_to_app }
			else
				message += " Unable to save to database"
				error_msg_string = stringify_error_messages new_user if new_user
				response = { "error_server" => error_msg_string }
			end
			puts "iPhone -Create_Account- response => #{response} && #{response.to_json}"
			format.json { render json: response }
		end
	end

	def login

		response  = {}
		email     = params["email"].downcase
		password  = params["password"]
		pn_token  = params["pn_token"] || nil

		if password == "hNgobEA3h_mNeQOPJcVxuA"
			password = "0"
		end

		if email.nil? || password.nil?
			response["error_iphone"]     = "Data not received."
		else
			user = User.find_by_email(email)
			logger.debug "logger.debug PASSWORD - #{user.inspect} - #{params['password']} - #{password}"

			if user && user.authenticate(password)
				user.pn_token       = pn_token if pn_token
				response["server"]  = user.providers_to_iphone
				response["user"]    = user.serialize(true)
			else
				response["error"]   = "Invalid email/password combination"
			end
		end

		respond_to do |format|
			puts "LOGIN response => #{response}"
			format.json { render json: response }
		end
	end

	def login_social

		response  = {}
		origin    = params["origin"].downcase
		pn_token  = params["pn_token"] || nil
		if origin == 'f'
			facebook_id = params["facebook_id"]
		else
			twitter     = params["twitter"]
		end

		if facebook_id.nil? && twitter.nil?
			response["error_iphone"] = "Data not received."
		else
			if origin == 'f'
				user = User.find_by_facebook_id(facebook_id)
				msg  = "Facebook Account"
				resp_key = "facebook"
			else
				user = User.find_by_twitter(twitter)
				msg  = "Twitter Account"
				resp_key = "twitter"
			end
			if user
				user.pn_token       = pn_token if pn_token
				response["server"]  = user.providers_to_iphone
				response["user"]    = user.serialize(true)
			else
				response[resp_key]  = "#{msg} not in Drinkboard database "
			end
		end

		respond_to do |format|
			puts "LOGIN WITH SOCIAL MEDIA response => #{response}"
			format.json { render json: response }
		end
	end

	def going_out

					# send the button status in params["public"]
					# going out is YES , returning home is NO
		response  = {}
		begin
			user  = User.find_by_remember_token(params["token"])
			if    params["public"] == "YES"
				user.update_attributes(is_public: true) if !user.is_public
			elsif params["public"] == "NO"
				user.update_attributes(is_public: false) if user.is_public
			else
				response["error_public"] = "did not receiver public params correctly"
			end
					# return the updated user.is_public value
					# if params["public"] is not sent, is_public is not changed
			response["public"] = user.is_public
		rescue
			response["error"] = "could not find user in database"
		end

		respond_to do |format|
			logger.debug response
			puts "response => #{response}"
			format.json { render json: response }
		end
	end

	def gifts

		user  = User.find_by_remember_token(params["token"])
		gifts = Gift.get_gifts(user)
		gift_hash = hash_these_gifts(gifts, GIFT_REPLY, true)

		respond_to do |format|
			logger.debug gift_hash
			format.json { render text: gift_hash.to_json }
		end
	end

	def regift

		user  = User.find_by_remember_token(params["token"])
		gift  = Gift.find(params["gift_id"].to_i)
		if gift.receiver == user
			receiver_id = params["regifter_id"] || nil
			receiver = User.find(receiver_id.to_i)
			message  = params["message"]     || nil
			new_gift = gift.regift(receiver, message)
		else
			response["error_iphone"]    =  " User cannot regift gift #{gift.id}"
		end
		respond_to do |format|
			if new_gift.save
				response["success"]       = "ReGifted - Thank you!"
			else
				response["error_server"]  = " ReGift unable to process to database."
			end
			puts "response => #{response}"
			format.json { render json: response }
		end
	end

	def buys

		response = {}
		if user = authenticate_app_user(params["token"])
			puts "authenticate_app_user INHERITS !!!!"

			gifts, past_gifts     = Gift.get_buy_history(user)
			gift_array            = array_these_gifts(gifts, BUY_REPLY, true, true)
			past_gift_array       = array_these_gifts(past_gifts, BUY_REPLY, true, true)
			response["active"]    = gift_array
			response["completed"] = past_gift_array
			logmsg = gift_array[0]
		else
			response["error"] = unauthorized_user
		end
		respond_to do |format|
			# logger.debug response
			puts "response => #{logmsg}"
			format.json { render json: response }
		end
	end

	def activity

		@user     = User.find_by_remember_token(params["token"])
		gifts     = Gift.get_activity
		gift_hash = hash_these_gifts(gifts, BOARD_REPLY)

		respond_to do |format|
			logger.debug gift_hash
			format.json { render text: gift_hash.to_json }
		end
	end

	def locations

		# @user  = User.find_by_remember_token(params["token"])
		providers = Provider.all
		menus     = {}
		providers.each do |p|
			if p.menu_string
				obj   = ActiveSupport::JSON.decode p.menu_string.data
				x     = obj.keys.pop
				value = obj[x]
				value["sales_tax"]  = p.sales_tax || "7.25"
				menus.merge!(obj)
			end
		end
		respond_to do |format|
			logger.debug menus
			format.json { render text: menus.to_json }
		end
	end

	def update_photo

		response = {}
		begin
			user  = User.find_by_remember_token(params["token"])
		rescue
			response["error"] = "User not found from remember token"
		end

		data_obj = JSON.parse params["data"]
		puts "#{data_obj}"

		respond_to do |format|
			if data_obj.nil?
				response["error_iphone"]   = "Photo URL not received correctly from iphone. "
			else
				if user.update_attributes(iphone_photo: data_obj["iphone_photo"], use_photo: "ios" )
					response["success"]      = "Photo Updated - Thank you!"
				else
					response["error_server"] = "Photo URL unable to process to database."
				end
			end

			puts "IC -UpdatePhoto- response => #{response}"
			format.json { render json: response }
		end
	end

	def active_orders

		response   = {}
		begin
			user     = User.find_by_remember_token(params["token"])
			provider = Provider.find(params["provider_id"].to_i)
		rescue
			response["error"] = "User/Provider not found from remember token/ provider id"
		end
					# get gifts from db that are open or notified
		gifts = Gift.get_provider provider
					# hash gifts into form for iphone
					# include total , tax, tip
		gift_hash  = hash_these_gifts(gifts, MERCHANT_REPLY, false, true)
		respond_to do |format|
			puts gift_hash
			format.json { render text: gift_hash.to_json }
		end
	end

	def completed_orders

		response   = {}
		begin
			user     = User.find_by_remember_token(params["token"])
			provider = Provider.find(params["provider_id"].to_i)
		rescue
			response["error"] = "User/Provider not found from remember token/ provider id"
		end
					# get gifts from db that are completed
		completed_gifts = Gift.get_history_provider provider
					# hash gifts into form for iphone
					# include total , tax, tip
		gift_hash  = hash_these_gifts(completed_gifts, COMPLETED_REPLY, false, true)
		respond_to do |format|
			puts gift_hash
			format.json { render text: gift_hash.to_json }
		end
	end

	private

		def hash_these_users(obj, send_fields)
			user_hash = {}
			index = 1
			obj.each do |g|
				user_obj = g.serializable_hash only: send_fields
				user_hash["#{index}"] = user_obj.each_key do |key|
					value = user_obj[key]
					user_obj[key] = value.to_s
				end
				user_obj["photo"] = g.get_photo
				index += 1
			end
			return user_hash
		end

		def hash_these_gifts(obj, send_fields, address_get=false, receiver=false)
			gift_hash = {}
			index = 1
			obj.each do |g|

				if g.created_at
					time = g.created_at.to_time
				else
					time = g.updated_at.to_time
				end
				time_string = time_ago_in_words(time)

				gift_obj = g.serializable_hash only: send_fields
				gift_hash["#{index}"] = gift_obj.each_key do |key|
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

				gift_obj["time_ago"] = time_string
				gift_obj["redeem_code"] = add_redeem_code(g)

				index += 1
			end
			return gift_hash
		end

		def create_user_object(data)
			obj = JSON.parse data
			#puts "CREATE USER OBJECT parse = #{obj}"
			obj.symbolize_keys!
			User.new(obj)
		end

end