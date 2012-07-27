class IphoneController < AppController
  
  LOGIN_REPLY = ["first_name", "last_name" , "address" , "city" , "state" , "zip", "remember_token", "email", "phone"]  
  GIFT_REPLY = ["giver_id", "giver_name", "item_id", "item_name", "provider_id", "provider_name", "category", "quantity", "message", "created_at", "status"]
  BUY_REPLY = ["receiver_id", "receiver_name", "item_id", "item_name", "provider_id", "provider_name", "category", "quantity", "message", "created_at", "status"]
  BOARD_REPLY = ["receiver_id", "receiver_name", "item_id", "item_name", "provider_id", "provider_name", "category", "quantity", "message", "created_at", "status", "giver_id", "giver_name", "item_id", "item_name", "provider_id", "provider_name", "category", "quantity", "message", "created_at", "status"] 
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
    gift_hash = hash_this(@gifts, GIFT_REPLY)

    
    respond_to do |format|
      format.json { render text: gift_hash.to_json }
    end
  end

  def buys
    @user  = User.find_by_remember_token(params["token"])
    @gifts = Gift.get_buy_history(@user)
    gift_hash = hash_this(@gifts, BUY_REPLY)
    
    respond_to do |format|
      #format.json { render json: @gifts, only: GIFT_REPLY }
      format.json { render text: gift_hash.to_json }
    end
  end
  
  def activity
    @user  = User.find_by_remember_token(params["token"])
    @gifts = Gift.get_activity
    gift_hash = hash_this(@gifts, BOARD_REPLY) 
    
    respond_to do |format|
      format.json { render text: gift_hash.to_json }
    end
  end
  
  def hash_this(obj, send_fields)
    gift_hash = {}
    index = 1 
    obj.each do |g|
      gift_obj = g.serializable_hash only: send_fields
      gift_hash["#{index}"] = gift_obj.each_key do |key|
        value = gift_obj[key]
        gift_obj[key] = value.to_s
      end
      gift_obj["category"] = g.item.category.to_s
      index += 1
    end
    return gift_hash
  end
  
  private
  
    def create_user_object(data)
      obj = JSON.parse data
      obj.symbolize_keys!
      User.new(obj)
    end

end
