class IphoneController < AppController
  
  LOGIN_REPLY = ["first_name", "last_name" , "address" , "city" , "state" , "zip", "remember_token", "email", "phone"]  
  GIFT_REPLY  = ["giver_id", "giver_name", "item_id", "item_name", "provider_id", "provider_name", "category", "quantity", "message", "created_at", "status", "gift_id"]
  BUY_REPLY   = ["receiver_id", "receiver_name", "item_id", "item_name", "provider_id", "provider_name", "category", "quantity", "message", "created_at", "status", "gift_id"]
  BOARD_REPLY = ["receiver_id", "receiver_name", "item_id", "item_name", "provider_id", "provider_name", "category", "quantity", "message", "created_at", "status", "giver_id", "giver_name", "gift_id"] 
  PROVIDER_REPLY = ["receiver_id", "receiver_name", "item_id", "item_name", "provider_id", "provider_name", "category", "quantity", "status", "redeem_code", "special_instructions", "created_at", "giver_id", "price", "total",  "giver_name", , "gift_id"]
  
  def create_account
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
      format.json { render text: response.to_json }
    end
  end
  
  def login
    email = params["email"]
    password = params["password"]
    
    if email.nil? || password.nil?
      response = { "error" => "Data not received."}.to_json
    else
      user = User.find_by_email(email)     
      if user && user.authenticate(password)
        response = user.to_json only: LOGIN_REPLY
      else
        response = { "error" => "Invalid email/password combination" }.to_json
      end
    end
    
    respond_to do |format|
      format.json { render text: response }
    end
  end
  
  def gifts
    @user  = User.find_by_remember_token(params["token"])
    @gifts = Gift.get_gifts(@user)
    gift_hash = hash_these_gifts(@gifts, GIFT_REPLY)

    
    respond_to do |format|
      format.json { render text: gift_hash.to_json }
    end
  end

  def buys
    @user  = User.find_by_remember_token(params["token"])
    @gifts = Gift.get_buy_history(@user)
    gift_hash = hash_these_gifts(@gifts, BUY_REPLY)
    
    respond_to do |format|
      #format.json { render json: @gifts, only: GIFT_REPLY }
      format.json { render text: gift_hash.to_json }
    end
  end
  
  def activity
    @user  = User.find_by_remember_token(params["token"])
    @gifts = Gift.get_activity
    gift_hash = hash_these_gifts(@gifts, BOARD_REPLY) 
    
    respond_to do |format|
      format.json { render text: gift_hash.to_json }
    end
  end
  
  def provider
    # @user  = User.find_by_remember_token(params["token"])
    @provider = Provider.find(params["provider_id"])
    @gifts = Gift.get_provider(@provider)
    gift_hash = hash_these_gifts(@gifts, PROVIDER_REPLY) 
    respond_to do |format|
      format.json { render text: gift_hash.to_json }
    end
  end
  
  def locations
    # @user  = User.find_by_remember_token(params["token"])
    @providers = Provider.all
    menus = {}
    @providers.each do |p|
      menu = JSON.parse p.menu_string.data
      menus.merge!(menu)
    end
    respond_to do |format|
      format.json { render text: menus.to_json }
    end
  end
  
  def create_gift
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
    begin
      receiver = User.find_by_phone(params["phone"])
      gift.receiver_name = receiver.username
      gift.receiver_id = receiver.id
    rescue
      message += "The person you've bought a gift for is not in our database. "
      gift.receiver_phone = params["phone"]
    end
    response = { "error" => message } if message != "" 
    respond_to do |format|
      if gift.save
        response["success"] = "Gift received - Thank you!"
        format.json { render json: response.to_json }
      else
        response["error"] += " Gift unable to process to database." 
        format.json { render json: response.to_json }
      end
    end  
  end

  def create_redeem
    @message = ""
    response = {}
    redeem_obj = JSON.parse params["redeem"]
    if redeem_obj.nil?
      @message = "data did not transfer. "
      redeem = Redeem.new
    else
      redeem = Redeem.new(redeem_obj)
    end
    begin
      receiver = User.find_by_remember_token(params["token"])
    rescue
      @message = "Couldn't identify app user. "
    end
    begin
      gift = Gift.find(params["redeem"]["gift_id"])
    rescue
      @message += " Could not locate gift in the database"    
    end
    response = { "error" => @message } if @message != "" 

    respond_to do |format|
      if redeem.save
        redeem.gift.update_attributes({status:'notified'},{redeem_id: redeem})
        response["success"] = redeem.redeem_code
        format.json { render text: response.to_json}
      else
        @message += " Gift unable to process to database. Please retry later."
        response["error"] = @message 
        format.json { render text: response.to_json }
      end
    end
  end
  
  def create_order
    @message = ""
    response = {} 
    order_obj = JSON.parse params["data"]
    if order_obj.nil?
      @message = "Data not received correctly. "
      order = Order.new
    else
      order = Order.new(order_obj)
    end
    begin
      provider_user = User.find_by_remember_token(params["token"])
      provider = Provider.find(provider_user.provider_id)
    rescue
      @message = "Couldn't identify app user. "
    end



  end
  
  private
  
    def hash_these_gifts(obj, send_fields)
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
