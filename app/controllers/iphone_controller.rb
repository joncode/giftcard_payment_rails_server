class IphoneController < AppController

  
  LOGIN_REPLY = ["id", "first_name", "last_name" , "address" , "city" , "state" , "zip", "remember_token", "email", "phone", "provider_id"]  
  GIFT_REPLY  = ["giver_id", "giver_name", "item_id", "item_name", "provider_id", "provider_name", "category", "quantity", "message", "created_at", "status", "id"]
  BUY_REPLY   = ["receiver_id", "receiver_name", "item_id", "item_name", "provider_id", "provider_name", "category", "quantity", "message", "created_at", "status", "id"]
  BOARD_REPLY = ["receiver_id", "receiver_name", "item_id", "item_name", "provider_id", "provider_name", "category", "quantity", "message", "created_at", "status", "giver_id", "giver_name", "id"] 
  PROVIDER_REPLY = ["receiver_id", "receiver_name", "item_id", "item_name", "provider_id", "provider_name", "category", "quantity", "status", "redeem_id", "redeem_code", "special_instructions", "created_at", "giver_id", "price", "total",  "giver_name", "id"]
  USER_REPLY = ["id", "first_name", "last_name", "email", "phone", "facebook_id"]



  
  # def time_ago_in_words
  #   super
  #   ActiveRecord::Base.logger = Logger.new("in method")
  # end

  
  def create_account
    logger.info "Create Account"
    data = params["data"]

    if data.nil?
      message = "Data not received correctly. "
    else
      new_user = create_user_object(data) 
      message = ""          
    end
    
    respond_to do |format|
      if !data.nil? && new_user.save
        response = { "success" => new_user.remember_token }
      else
        message += " Unable to save to database" 
        response = { "error" => message }
      end
      logger.info response
      format.json { render text: response.to_json }
    end
  end
  
  def login
    logger.info "Login"
    email = params["email"]
    password = params["password"]
    
    if email.nil? || password.nil?
      response = { "error" => "Data not received."}.to_json
    else
      user = User.find_by_email(email)     
      if user && user.authenticate(password)
        if user.providers.count > 0
          user.provider_id = user.providers.dup.shift.id
        end
        response = user.to_json only: LOGIN_REPLY
      else
        response = { "error" => "Invalid email/password combination" }.to_json
      end
    end
    
    respond_to do |format|
      logger.info response
      format.json { render text: response }
    end
  end
  
  def gifts
    logger.info "Gifts"
    @user  = User.find_by_remember_token(params["token"])
    @gifts = Gift.get_gifts(@user)
    gift_hash = hash_these_gifts(@gifts, GIFT_REPLY, true)
  
    respond_to do |format|
      logger.debug gift_hash
      format.json { render text: gift_hash.to_json }
    end
  end

  def buys
    logger.info "Buys"
    @user  = User.find_by_remember_token(params["token"])
    @gifts, @past_gifts = Gift.get_buy_history(@user)
    gift_hash = hash_these_gifts(@gifts, BUY_REPLY)
    
    respond_to do |format|
      #format.json { render json: @gifts, only: GIFT_REPLY }
      logger.debug gift_hash
      format.json { render text: gift_hash.to_json }
    end
  end
  
  def drinkboard_users
    @user  = User.find_by_remember_token(params["token"])
    @users = User.find(:all, :conditions => ["id != ?", @user.id])    
    user_hash = hash_these_users(@users, USER_REPLY)
    
    respond_to do |format|
      logger.debug user_hash
      format.json { render text: user_hash.to_json }
    end
  end
  
  def activity
    logger.info "Activity"
    @user  = User.find_by_remember_token(params["token"])
    @gifts = Gift.get_activity
    gift_hash = hash_these_gifts(@gifts, BOARD_REPLY) 
    
    respond_to do |format|
      logger.debug gift_hash
      format.json { render text: gift_hash.to_json }
    end
  end
  
  def provider
    logger.info "Provider"
    # @user  = User.find_by_remember_token(params["token"])
    @provider = Provider.find(params["provider_id"])
    @gifts = Gift.get_provider(@provider)

    gift_hash = hash_these_gifts(@gifts, PROVIDER_REPLY) 

    respond_to do |format|
      logger.info gift_hash
      format.json { render text: gift_hash.to_json }
    end
  end
  
  def locations
    logger.info "Locations"
    # @user  = User.find_by_remember_token(params["token"])
    @providers = Provider.all
    menus = {}
    @providers.each do |p|
      menu = JSON.parse p.menu_string.data
      menus.merge!(menu)
    end
    respond_to do |format|
      logger.debug menus
      format.json { render text: menus.to_json }
    end
  end
  
  def create_gift 
    logger.info "Create Gift"
    message = ""
    response = {}
    gift_obj = JSON.parse params["gift"]
    if gift_obj.nil?
      message = "data did not transfer. "
      gift = Gift.new
    else
      gift = Gift.new(gift_obj)
    end
    begin
      giver = User.find_by_remember_token(params["token"])
      gift.giver_id = giver.id
      gift.giver_name = giver.username
    rescue
      message += "Couldn't identify app user. "
    end
    
    # for drinkboard users this will work because we are getting the receiver info from drinkboard
    # for facebook users this will bnot work because we are not connecting the fb user with a drinkboard account
    
    response = { "error" => message } if message != "" 
    respond_to do |format|
      if gift.save
        response["success"] = "Gift received - Thank you!"
      else
        response["error_server"]  = " Gift unable to process to database." 
      end
      logger.info response
      format.json { render json: response.to_json }
    end  
  end

  def create_redeem
    logger.info "Create Redeem"
    message = ""
    response = {}
    redeem_obj = JSON.parse params["redeem"]
    if redeem_obj.nil?
      message = "data did not transfer. "
      redeem = Redeem.new
    else
      redeem = Redeem.new(redeem_obj)
    end
    begin
      receiver = User.find_by_remember_token(params["token"])
    rescue
      message += "Couldn't identify app user. "
    end

    response = { "error" => message } if message != "" 

    respond_to do |format|
      if redeem.save
        response["success"] = redeem.redeem_code
      else
        message += " Gift unable to process to database. Please retry later."
        response["error_server"] = message 
      end
      logger.info response
      format.json { render text: response.to_json}
    end
  end

  def create_order
    logger.info "Create Order"
    message = ""
    response = {} 
    order_obj = JSON.parse params["data"]
    if order_obj.nil?
      message = "Data not received correctly. "
      order = Order.new
    else
      order = Order.new(order_obj)
    end
    begin
      provider_user = User.find_by_remember_token(params["token"])
    rescue
      message += "Couldn't identify app user. "
    end
    begin
    #   redeem = Redeem.find(order.redeem_id)
    #   redeem_code = redeem.redeem_code
      redeem = Redeem.find_by_gift_id(order.gift_id)
    rescue
      message += " Could not find redeem code via gift_id. "
    end
    if redeem
      redeem_code = redeem.redeem_code
    else
      redeem_code = "X"
    end
    response = { "error" => message } if message != "" 

    respond_to do |format|
      if order.redeem_code == redeem_code
        if order.save
          response["success"] = " Sale Confirmed. Thank you!"
        else
          # order.gift.update_attribute(:status, "redeemed")
          response["error_server"] = " Order not processed - database error"
        end
      else
        response["error_server"] = " the redeem code you entered did not match. "
      end
      logger.info response
      format.json { render text: response.to_json }
    end  
  end
  
  def update_photo
    logger.info "Update Photo"
    message = ""
    response = {} 
    @user  = User.find_by_remember_token(params["token"])
    order_obj = JSON.parse params["data"]
 
    respond_to do |format|
      if order_obj.nil?
        message = "Photo URL not received correctly from iphone. "
      else
        @user.photo = order_obj.photo
        if @user.update_attributes(photo: @user.photo)
          response["success"] = "Photo Updated - Thank you!"
        else
          response["error_server"]  = "Photo URL unable to process to database." 
        end
      end

      logger.info response
      format.json { render json: response.to_json }
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
        index += 1
      end
      return user_hash
    end
  
    def hash_these_gifts(obj, send_fields, address_get=false)
      gift_hash = {}
      index = 1 
      obj.each do |g|
      
        ### >>>>>>>    item_name pluralizer
        # g.item_name = g.item_name.pluralize if g.quantity > 1
        ###  7/27 6:45 UTC
      
        time = g.created_at.to_time
        time_string = time_ago_in_words(time)
      
        gift_obj = g.serializable_hash only: send_fields
        gift_hash["#{index}"] = gift_obj.each_key do |key|
          value = gift_obj[key]
          gift_obj[key] = value.to_s
        end
        
        if address_get
          address = g.provider.address
          city = g.provider.city
          state = g.provider.state
          zip = g.provider.zip
          provider_address_string = "#{address} \n#{city} #{state} #{zip}"
          gift_obj["provider_address"] = provider_address_string
        end
        gift_obj["time_ago"]    = time_string
      
        ### >>>>>>>    this is not stored in gift object
        gift_obj["redeem_code"] = add_redeem_code(g)
        ###  07-27 9:08 UTC
            
        index += 1
      end
      return gift_hash
    end
    
    def add_redeem_code(obj)
      if obj.status == "notified" 
        obj.redeem.redeem_code
      else
        "none"
      end
    end
    
    def create_user_object(data)
      obj = JSON.parse data
      obj.symbolize_keys!
      User.new(obj)
    end

end
