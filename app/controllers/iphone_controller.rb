class IphoneController < AppController

	before_filter :authenticate_services,     only: [:regift]

	def create_account

		data     = params["data"]
		pn_token = params["pn_token"] || nil
		#puts " Here is the PARAMS obj #{params}"

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
				user_to_app       = {"user_id" => new_user.id, "token" => new_user.remember_token}
				response          = { "success" => user_to_app }
			else
				message          += " Unable to save to database"
				error_msg_string  = stringify_error_messages new_user if new_user
				response          = { "error_server" => error_msg_string }
			end
			@app_response = response
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

		if email.blank? || password.blank?
			response["error_iphone"]     = "Data not received."
		else
			user = User.find_by_email_and_active(email, true)
			logger.debug "logger.debug PASSWORD - #{user.inspect} - #{params['password']} - #{password}"

			if user && user.authenticate(password)
				user.pn_token       = pn_token if pn_token
				#response["server"]  = user.providers_to_iphone
				response["user"]    = user.serialize(true)
			else
				response["error"]   = "Invalid email/password combination"
			end
		end

		respond_to do |format|
			@app_response = "iPhoneC #{response}"
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

		if facebook_id.blank? && twitter.blank?
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
				#response["server"]  = user.providers_to_iphone
				response["user"]    = user.serialize(true)
			else
				response[resp_key]  = "#{msg} not in Drinkboard database "
			end
		end

		respond_to do |format|
			@app_response = "iPhoneC #{response}"
			format.json { render json: response }
		end
	end

	def cities

		response = [{"name"=>"Las Vegas", "state"=>"Nevada", "city_id"=>1, "photo"=>"d|v1378747548/las_vegas_xzqlvz.jpg"}, {"name"=>"San Francisco", "state"=>"California", "city_id"=>4, "photo"=>"d|v1378747548/san_francisco_hv2bsc.jpg"}, {"name"=>"San Diego", "state"=>"California", "city_id"=>3, "photo"=>"d|v1378747548/san_diego_oj3a5w.jpg"}, {"name"=>"New York", "state"=>"New York", "city_id"=>2, "photo"=>"d|v1378747548/new_york_vks0yh.jpg"}]
		respond_to do |format|
			@app_response = "iPhoneC #{response}"
			format.json { render json: response }
		end
	end

	def going_out

			# send the button status in params["public"]
			# going out is YES , returning home is NO
		response  = {}
		begin
			user  = User.app_authenticate(token)
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
			@app_response = "iPhoneC #{response}"
			format.json { render json: response }
		end
	end

	def regift

        recipient_data = JSON.parse params["receiver"]
        details 	   = JSON.parse params["data"]
        gift_regifter  = GiftRegifter.new(recipient_data, details)

        if gift_regifter.create
        	success gift_regifter.response
        else
        	fail  	gift_regifter.response
        end
        respond
	end

	def buys

		response = {}
		if user = authenticate_app_user(params["token"])
			gifts, past_gifts     = Gift.get_buy_history(user)
			gift_array            = array_these_gifts(gifts, BUY_REPLY, true, true)
			past_gift_array       = array_these_gifts(past_gifts, BUY_REPLY, true, true)
			response["active"]    = gift_array
			response["completed"] = past_gift_array
			logmsg = "#{gift_array[0]} + #{past_gift_array[0]}"
		else
			response["error"] = unauthorized_user
			logmsg = "Error unauthorized user"
		end
		respond_to do |format|
			# logger.debug response

			@app_response = "iPhoneC #{logmsg}"
			# puts "full response => #{response}"
			format.json { render json: response }
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
			user  = User.app_authenticate(token)
		rescue
			response["error"] = "User not found from remember token"
		end
		if params["data"].kind_of? String
			data_obj = JSON.parse params["data"]
		else
			data_obj = params["data"]
		end
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


private


    def make_user_with_hash(user_data_hash)
        recipient               = User.new
        recipient.first_name    = user_data_hash["name"]
        recipient.email         = user_data_hash["email"]
        recipient.phone         = user_data_hash["phone"]
        recipient.facebook_id   = user_data_hash["facebook_id"]
        recipient.twitter       = user_data_hash["twitter"]
        return recipient
    end

	def create_user_object(data)
		if data.kind_of? String
			obj = JSON.parse data
		else
			obj = data
		end
		puts "CREATE USER OBJECT parse = #{obj}"
		# obj.symbolize_keys!
		User.new(obj)
	end

end