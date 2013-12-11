class JsonController < ActionController::Base
    include ActionView::Helpers::DateHelper
    include CommonUtils
    include JsonHelper

	skip_before_filter   :verify_authenticity_token
    #before_filter        :down_for_maintenance
    before_filter        :log_request_header
    before_filter        :method_start_log_message
    after_filter         :cross_origin_allow_header
    after_filter         :method_end_log_message

    UPDATE_REPLY    = ["id", "first_name", "last_name" , "address" , "city" , "state" , "zip", "email", "phone", "birthday", "sex", "twitter", "facebook_id"]
    GIFT_REPLY      = ["giver_id", "giver_name", "provider_id", "provider_name", "message", "status"]
    MERCHANT_REPLY  = GIFT_REPLY + [ "order_num"]
    ADMIN_REPLY     = GIFT_REPLY + [ "receiver_id", "receiver_name", "service"]
    BUY_REPLY       = ["total", "receiver_id", "receiver_name", "provider_id", "provider_name", "message", "created_at", "updated_at", "status", "id"]


    rescue_from ActiveRecord::RecordNotFound, :with => :not_found

    def not_found
        head 404
    end

    def bad_request
        head 400
    end

    def array_these_gifts obj, send_fields, address_get=false, receiver=false, order_num=false
        gifts_ary = []
        index = 1
        obj.each do |g|

            gift_obj = g.serializable_hash only: send_fields

            gift_obj.each_key do |key|
                value = gift_obj[key]
                gift_obj[key] = value.to_s
            end

            gift_obj["shoppingCart"] = JSON.parse(g.shoppingCart)

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
                gift_obj["provider_photo"] = provider.get_photo
                gift_obj["provider_phone"] = provider.phone
                gift_obj["city"]           = provider.city
                gift_obj["sales_tax"]      = provider.sales_tax
                gift_obj["live"]           = provider.live_int
                gift_obj["latitude"]       = provider.latitude
                gift_obj["longitude"]      = provider.longitude

                    # add the full provider address
                if address_get
                  gift_obj["provider_address"] = provider.complete_address
                end
                gift_obj["time_ago"]   = time_ago_in_words(g.created_at.to_time)
            else

                gift_obj["total"]    = g.total
                gift_obj["server"]   = g.order.server_code if g.order
                if (g.updated_at > (Time.now  - 1.day))
                    gift_obj["time_ago"] = g.updated_at.to_formatted_s(:merchant)
                else
                    gift_obj["time_ago"] = g.updated_at.to_formatted_s(:merchant_date)
                end
            end

            gift_obj["gift_id"]    = g.id.to_s
            gift_obj["updated_at"] = g.updated_at
            gift_obj["created_at"] = g.created_at

            gift_obj["redeem_code"]   = add_redeem_code(g)
            gifts_ary << gift_obj
        end
        return gifts_ary
    end

    def add_redeem_code obj
        if obj.status == "notified"
            obj.redeem.redeem_code
        else
            "none"
        end
    end

### API UTILITY METHODS

    def reject_if_not_exactly(allowed, data_hsh=nil)
        data_hsh ||= params["data"]
        check_ary = allowed - data_hsh.keys
        if check_ary.count == 0
            check_ary = data_hsh.keys - allowed
        end
        head :bad_request if check_ary.count != 0
    end

    def convert_if_json(data=nil)
        data ||= params["data"]
        if data.kind_of?(String)
            JSON.parse(data)
        else
            data
        end
    end

    def params_required(new_gift_hsh)
        got_unique_id = false
        if new_gift_hsh.kind_of? Hash
            got_unique_id = true if new_gift_hsh.include?("email")
            got_unique_id = true if new_gift_hsh.include?("phone")
            got_unique_id = true if new_gift_hsh.include?("facebook_id")
            got_unique_id = true if new_gift_hsh.include?("twitter")
        end
        head :bad_request unless got_unique_id
    end

    def nil_key_or_value(data=nil)
        data ||= params["data"]
        head :bad_request if data.nil?
    end

    def data_not_found?(data= nil)
        data ||= params["data"]
        head :not_found if data.nil?
    end

    def data_not_hash?(data=nil)
        data ||= params["data"]
        head :bad_request unless data.kind_of?(Hash)
    end

    def data_not_array?(data=nil)
        data ||= params["data"]
        head :bad_request unless data.kind_of?(Array)
    end

    def hash_empty?(data)
        head :bad_request unless data.count > 0
    end

    def data_blank?(data=nil)
        data ||= params["data"]
        head :bad_request if data.blank?
    end

    def data_not_string?(data=nil)
        data ||= params["data"]
        head :bad_request unless data.kind_of?(String)
    end

    def params_bad_request(new_key=nil)
        key = new_key || ["data"]
        good_params = [ "id", "controller", "action", "format"] + key
        head :bad_request unless (params.keys - good_params).count == 0
    end

    def collection_bad_request(new_key=nil)
        key = new_key || ["data"]
        good_params = [ "controller", "action", "format"] + key
        head :bad_request unless (params.keys - good_params).count == 0
    end

    def respond(status=nil)
        response_code = status || :ok
        respond_to do |format|
            format.json { render json: @app_response, status: response_code }
        end
    end

    def success payload
        @app_response = { status: 1, data: payload }
    end

    def fail payload
        unless payload.kind_of?(Hash) || payload.kind_of?(String) || payload.kind_of?(Array)
            payload   = { "error" => payload.errors.messages }
        end
        @app_response = { status: 0, data: payload }
    end

    def authenticate_admin_tools
        token = request.headers["HTTP_TKN"]
        @admin_user = AdminUser.find_by(remember_token: token)
        if @admin_user
            puts "ADMT  -------------   #{@admin_user.name}   -----------------------"
        else
            head :unauthorized
        end
    end

    def authenticate_merchant_tools
        token = request.headers["HTTP_TKN"]
        @provider = Provider.unscoped.find_by(token: token)
        if @provider
            puts "MT  -------------   #{@provider.name}   -----------------------"
        else
            head :unauthorized
        end
    end

    def authenticate_general_token
        token = request.headers["HTTP_TKN"]
        head :unauthorized unless [APP_GENERAL_TOKEN, GENERAL_TOKEN, ANDROID_TOKEN].include?(token)
    end

    def authenticate_www_token
        token   = params["token"]
        head :unauthorized unless WWW_TOKEN == token
    end

    def authenticate_public_info token=nil
        true
    end

    def authenticate_services
        token         = params["token"]
        @current_user = User.app_authenticate(token)
        if @current_user
            puts "APP  -------------   #{@current_user.name}   -----------------------"
        else
            head :unauthorized
        end
    end

    def authenticate_customer
        token         = request.headers["HTTP_TKN"]
        @current_user = User.app_authenticate(token)
        if @current_user
            puts "APP  -------------   #{@current_user.name}   -----------------------"
        else
            head :unauthorized
        end
    end

#######

private

    def cross_origin_allow_header
        headers['Access-Control-Allow-Origin']   = "*"
        headers['Access-Control-Allow-Methods']  = 'POST, PUT, DELETE, GET, OPTIONS'
        headers['Access-Control-Request-Method'] = '*'
        headers['Access-Control-Allow-Headers']  = 'Origin, X-Requested-With, Content-Type, Accept, TKN, Mdot-Version, Android-Version'
    end

    def down_for_maintenance
        #@app_response = { "error" => "Server is down for maintenance.  Thank you for your patience. Be back shortly" }
        #respond
    end


end
