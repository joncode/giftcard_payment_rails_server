class AppController < ApplicationController
	include ActionView::Helpers::DateHelper
	GIFT_REPLY = ["giver_id", "giver_name", "item_id", "item_name", "provider_id", "provider_name", "category", "quantity", "message", "created_at", "status", "id"]
 	USER_REPLY = ["id", "first_name", "last_name", "email", "phone", "facebook_id"]

 	def gifts
	    puts "Gifts"
	    puts "#{params}"

	    user  = User.find_by_remember_token(params["token"])
	    if user
	    	gifts = Gift.get_gifts(user)
	    	gifts_array = array_these_gifts(gifts, GIFT_REPLY, true)
	  	else
	  		gift_hash = {"error" => "user was not found in database"}
	  		gifts_array = gift_hash
	  	end
	    respond_to do |format|
	      logger.debug gifts_array
	      format.json { render text: gifts_array.to_json }
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

	    def array_these_users(obj, send_fields)
			user_array = []
			obj.each do |u|
				user_obj = u.serializable_hash only: send_fields
				user_obj.each_key do |key|
				  value = user_obj[key]
				  user_obj[key] = value.to_s
				end
				user_obj["photo"] = u.get_photo
				user_array << user_obj
			end
			return user_array
	    end
 
end
