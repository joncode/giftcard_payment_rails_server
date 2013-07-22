class JsonController < ActionController::Base
    include ActionView::Helpers::DateHelper
    include CommonUtils
	skip_before_filter   :verify_authenticity_token
	before_filter 		 :method_start_log_message
	after_filter 		 :cross_origin_allow_header
	after_filter 		 :method_end_log_message

    UPDATE_REPLY    = ["id", "first_name", "last_name" , "address" , "city" , "state" , "zip", "email", "phone", "birthday", "sex", "twitter", "facebook_id"]
    GIFT_REPLY      = ["giver_id", "giver_name", "provider_id", "provider_name", "message", "status"]
    MERCHANT_REPLY  = GIFT_REPLY + [ "order_num"]
    ACTIVITY_REPLY  = GIFT_REPLY + [ "receiver_id", "receiver_name"]
    BUY_REPLY       = ["total", "receiver_id", "receiver_name", "provider_id", "provider_name", "message", "created_at", "updated_at", "status", "id"]

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
                    gift_obj["receiver_name"]   = g.receiver.username
                    gift_obj["receiver_id"]     = g.receiver.id
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
                gift_obj["giver_photo"]    = g.giver.get_photo
                provider                   = g.provider
                gift_obj["provider_photo"] = provider.get_image("photo")
                gift_obj["provider_phone"] = provider.phone
                gift_obj["city"]           = provider.city
                gift_obj["sales_tax"]      = provider.sales_tax
                gift_obj["live"]           = provider.live
                gift_obj["latitude"]       = provider.latitude
                gift_obj["longitude"]      = provider.longitude

                    # add the full provider address
                if address_get
                  gift_obj["provider_address"] = provider.complete_address
                end
                gift_obj["time_ago"] = time_ago_in_words(g.created_at.to_time)
            else
                # change total to location total
                gift_obj["total"]    = g.ticket_total_string
                gift_obj["subtotal"] = g.subtotal_string
                gift_obj["server"]   = g.order.server_code if g.order
                if (g.updated_at > (Time.now  - 1.day))
                    gift_obj["time_ago"] = g.updated_at.to_formatted_s(:merchant)
                else
                    gift_obj["time_ago"] = g.updated_at.to_formatted_s(:merchant_date)
                end
                gift_obj["updated_at"] = g.updated_at
            end

            gift_obj["gift_id"]  = g.id.to_s


            gift_obj["redeem_code"]   = add_redeem_code(g)
            gifts_ary << gift_obj
        end
        return gifts_ary
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

    def add_redeem_code(obj)
        if obj.status == "notified"
            obj.redeem.redeem_code
        else
            "none"
        end
    end

	def cross_origin_allow_header
		headers['Access-Control-Allow-Origin'] = "*"
		headers['Access-Control-Request-Method'] = '*'
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

 	def database_error_general
 		{ "Data Transfer Error"   => "Please Reset App" }
 	end

    def authentication_data_error
        { "Data Transfer Error"   => "Authentication Failed" }
    end

 	def stringify_error_messages(object)
 		msgs = object.errors.messages
 		msgs.stringify_keys!
 		msgs.each_key do |key|
 			value_as_array 	= msgs[key]
 			if value_as_array.kind_of? Array
 				value_as_string = value_as_array.join(' | ')
 			else
 				value_as_string = value_as_array
 			end
 			msgs[key] 		= value_as_string
 		end

 		return msgs
 	end

    def serialize_objs_in_ary ary
        ary.map { |o| o.serialize }
    end

    def extract_phone_digits(phone_raw)
        if phone_raw
            phone_match = phone_raw.match(VALID_PHONE_REGEX)
            phone       = phone_match[1] + phone_match[2] + phone_match[3]
        end
    end


end
