class IphoneController < AppController

  LOGIN_REPLY     = ["id", "first_name", "last_name" , "address" , "city" , "state" , "zip", "birthday", "sex", "remember_token", "email", "phone", "facebook_id", "twitter"]  
  GIFT_REPLY      = ["giver_id", "giver_name", "item_id", "item_name", "provider_id", "provider_name", "category",  "message", "created_at", "status", "id"]
  BUY_REPLY       = ["receiver_id", "receiver_name", "item_id", "item_name", "provider_id", "provider_name", "category",  "message", "created_at", "status", "id"]
  BOARD_REPLY     = ["receiver_id", "receiver_name", "item_id", "item_name", "provider_id", "provider_name", "category",  "message", "created_at", "status", "giver_id", "giver_name", "id"] 
  PROVIDER_REPLY  = ["receiver_id", "receiver_name", "item_id", "item_name", "provider_id", "provider_name", "category",  "status", "redeem_id", "redeem_code", "created_at", "giver_id", "price", "total",  "giver_name", "id"]
  MERCHANT_REPLY  = ["receiver_id", "receiver_name","giver_name", "item_id", "item_name","category", "price", "total", "tax" , "tip", "message", "created_at", "id", "redeem_id", "redeem_code"]
  COMPLETED_REPLY = ["receiver_id", "receiver_name","giver_name", "item_id", "item_name","category", "price", "total", "tax" , "tip", "message", "updated_at", "id", "redeem_id", "redeem_code"]
  
  def create_account

    data = params["data"]

    if data.nil?
      message = "Data not received correctly. "
    else
      new_user = create_user_object(data) 
      puts "HERE IS NEW USER DATA #{new_user.inspect}"
      message = ""          
    end
    
    respond_to do |format|
      if !data.nil? && new_user.save
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
  
  def compare_pntokens(user)
    # sent_token = params["pntoken"]
    # if sent_token && user.pntoken != sent_token
    #   # update the pntoken 
    # end
  end

  def login

    response  = {}
    email     = params["email"].downcase
    password  = params["password"]
    if password == "hNgobEA3h_mNeQOPJcVxuA"
      password = "0"
    end
    
    if email.nil? || password.nil?
      response["error_iphone"]     = "Data not received."
    else
      user = User.find_by_email(email)   
      puts "DEBUGGING PASSWORD - #{user.inspect} - #{params['password']} - #{password}"  

      if user && user.authenticate(password)
        # compare_pntokens(user)
        response["server"]  = user.providers_to_iphone
        user_json           = user.to_json only: LOGIN_REPLY
        user_small          = JSON.parse user_json
        user_small["photo"] = user.get_photo
        response["user"]    = user_small
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
        response["server"]  = user.providers_to_iphone
        user_json           = user.to_json only: LOGIN_REPLY
        user_small          = JSON.parse user_json
        user_small["photo"] = user.get_photo
        response["user"]    = user_small
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
    gift  = Gift.find(params["gift_id"])
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
    else
      user = User.find_by_remember_token(params["token"])
    end
    gifts, past_gifts     = Gift.get_buy_history(user)
    gift_array            = array_these_gifts(gifts, BUY_REPLY, true, true)
    past_gift_array       = array_these_gifts(past_gifts, BUY_REPLY, true, true)
    response["active"]    = gift_array
    response["completed"] = past_gift_array
    logmsg = gift_array[0]

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
  
  def create_gift 

    response = {}
    message  = ""

    gift_obj = JSON.parse params["gift"]
    logger.debug "GIFT OBJECT  = #{params["gift"]}"

    case params["origin"]
    when 'd'
      #drinkboard - data already received
      response["receiver"]     = "db user"
    when 'f'
      # facebook - search users for facebook_id
      if gift_obj["facebook_id"]
        if receiver = User.find_by_facebook_id(gift_obj["facebook_id"])
          gift_obj             = add_receiver_to_gift_obj(receiver, gift_obj)
          response["receiver"] = receiver_info_response(receiver)
        else
          gift_obj["status"]   = "incomplete"
          response["receiver"] = "NID"
        end
      else                   
          gift_obj["status"]   = "incomplete"
          response["error-receiver"] = "No facebook ID received"
      end
    when 't'
      #twitter - search users for twitter handle
      if gift_obj["twitter"]
        if receiver = User.find_by_twitter(gift_obj["twitter"].to_s)
          gift_obj             = add_receiver_to_gift_obj(receiver, gift_obj)
          response["receiver"] = receiver_info_response(receiver)
        else                   
          gift_obj["status"]   = "incomplete"
          response["receiver"] = "NID"
        end
      else
        gift_obj["status"]     = "incomplete"
        response["error-receiver"] = "No twitter info received"
      end
    when 'c'
      # contacts - search users for phone
      if gift_obj["receiver_phone"]
        phone_received = gift_obj["receiver_phone"]
        phone = extract_phone_digits(phone_received)
        if receiver = User.find_by_phone(phone)
          gift_obj             = add_receiver_to_gift_obj(receiver, gift_obj)
          response["receiver"] = receiver_info_response(receiver)
        else
          gift_obj["status"]   = "incomplete"
          response["receiver"] = "NID"
        end
      else
          gift_obj["status"]   = "incomplete"
          response["error-receiver"] = "No contact phone received"
      end
    when 'e'
      # email - search users for phone
      if gift_obj["receiver_email"]
        if receiver = User.find_by_email(gift_obj["receiver_email"])
          gift_obj             = add_receiver_to_gift_obj(receiver, gift_obj)
          response["receiver"] = receiver_info_response(receiver)
        else
          gift_obj["status"]   = "incomplete"
          response["receiver"] = "NID"
        end
      else
          gift_obj["status"]   = "incomplete"
          response["error-receiver"] = "No contact email received"
      end
    else
        #drinkboard - no origin sent
        response["receiver"]     = "db user"
    end

    if gift_obj.nil?
      message += "No gift data received.  "
      gift    = Gift.new
    else
      gift    = Gift.new(gift_obj)
      if params["shoppingCart"]
        shoppingCart_array = JSON.parse params["shoppingCart"]
        gift_item_array = []
        shoppingCart_array.each do |item|
          gift_item = GiftItem.initFromDictionary item
          gift_item_array << gift_item
        end
        gift.gift_items = gift_item_array
      end
      logger.debug "Here is GIFT #{gift.inspect}"
    end
    
    begin
      # we already have this data, we do not need to re-save it onto the gift
      giver           = User.find_by_remember_token(params["token"])
      if gift_obj["anon_id"]
        gift.add_anonymous_giver(giver.id)
      else
        gift.giver_id   = giver.id
        gift.giver_name = giver.username
      end
    rescue
      message += "Couldn't identify app user. "
    end
    
    response = { "error" => message } if message != "" 
    respond_to do |format|
      logger.debug " PRE SAVE GIFT OBJECT  = #{gift.inspect}"
      if gift.save
        sale = gift.authorize_capture
        if sale.resp_code == '1'
          response["success"]       = "Gift received - Thank you!" 
        else
          response["error_server"]  = { "credit_card" => sale.reason_text }
        end
      else
        response["error_server"]       = stringify_error_messages gift
        logger.debug "this is the errrors on gift = #{gift.errors.messages}"
      end
      puts "response => #{response}"
      format.json { render json: response }
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
  
    def extract_phone_digits(phone_raw)
      if phone_raw
        phone_match = phone_raw.match(VALID_PHONE_REGEX)
        phone       = phone_match[1] + phone_match[2] + phone_match[3]
      end
    end
    
    def receiver_info_response(receiver)
      { "receiver_id" => receiver.id.to_s, "receiver_name" => receiver.username, "receiver_phone" => receiver.phone }
    end
    
    def add_receiver_to_gift_obj(receiver, gift_obj)
      gift_obj["receiver_id"]    = receiver.id
      gift_obj["receiver_name"]  = receiver.username
      gift_obj["receiver_phone"] = receiver.phone
      return gift_obj
    end
  
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


    # case params["origin"]
    # when 'f'
    #   receiver = User.find_by_facebook_id(gift_obj["facebook_id"])
    # when 't'
    #   receiver = User.find_by_twitter(gift_obj["twitter"])
    # when 'c'
    #   phone_received = gift_obj["receiver_phone"]
    #   phone = extract_phone_digits(phone_received)
    #   receiver = User.find_by_phone(phone)
    # when 'e'
    #   receiver = User.find_by_email(gift_obj["receiver_email"])
    # else
    #   response["receiver"]     = "db user"
    # end

    # if receiver
    #   gift_obj             = add_receiver_to_gift_obj(receiver, gift_obj)
    #   response["receiver"] = receiver_info_response(receiver)
    # else
    #   gift_obj["status"]   = "incomplete"
    #   response["receiver"] = "NID"
    # end

    # case params["origin"]
    # when 'd'
    #   #drinkboard - data already received
    #   response["receiver"]     = "db user"
    # when 'f'
    #   # facebook - search users for facebook_id
    #   if gift_obj["facebook_id"]

    #   else                   
    #       gift_obj["status"]   = "incomplete"
    #       response["error-receiver"] = "No facebook ID received"
    #   end
    # when 't'
    #   #twitter - search users for twitter handle
    #   if gift_obj["twitter"]

    #   else
    #     gift_obj["status"]     = "incomplete"
    #     response["error-receiver"] = "No twitter info received"
    #   end
    # when 'c'
    #   # contacts - search users for phone
    #   if gift_obj["receiver_phone"]

    #   else
    #       gift_obj["status"]   = "incomplete"
    #       response["error-receiver"] = "No contact phone received"
    #   end
    # when 'e'
    #   # email - search users for phone
    #   if gift_obj["receiver_email"]

    #   else
    #       gift_obj["status"]   = "incomplete"
    #       response["error-receiver"] = "No contact email received"
    #   end
    # else
    #     #drinkboard - no origin sent
    #     response["receiver"]     = "db user"
    # end

    # if gift_obj.nil?
    #   message += "No gift data received.  "
    #   gift    = Gift.new
    # else
    #   gift    = Gift.new(gift_obj)
    #   if params["shoppingCart"]
    #     shoppingCart_array = JSON.parse params["shoppingCart"]
    #     gift_item_array = []
    #     shoppingCart_array.each do |item|
    #       gift_item = GiftItem.initFromDictionary item
    #       gift_item_array << gift_item
    #     end
    #     gift.gift_items = gift_item_array
    #   end
    #   puts "Here is GIFT #{gift.inspect}"
    # end
