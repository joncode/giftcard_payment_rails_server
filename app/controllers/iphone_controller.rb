class IphoneController < AppController
 include ActionView::Helpers::DateHelper
 require 'logger'
  
  LOGIN_REPLY = ["first_name", "last_name" , "address" , "city" , "state" , "zip", "remember_token", "email", "phone"]  
  GIFT_REPLY  = ["giver_id", "giver_name", "item_id", "item_name", "provider_id", "provider_name", "category", "quantity", "message", "created_at", "status"]
  BUY_REPLY   = ["receiver_id", "receiver_name", "item_id", "item_name", "provider_id", "provider_name", "category", "quantity", "message", "created_at", "status"]
  BOARD_REPLY = ["receiver_id", "receiver_name", "item_id", "item_name", "provider_id", "provider_name", "category", "quantity", "message", "created_at", "status", "giver_id", "giver_name"] 
  PROVIDER_REPLY = ["receiver_id", "receiver_name", "item_id", "item_name", "provider_id", "provider_name", "category", "quantity", "status", "redeem_code", "special_instructions", "created_at", "giver_id", "price", "total",  "giver_name"]


  
  def time_ago_in_words
    super
    ActiveRecord::Base.logger = Logger.new("in method")
  end
  
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
  
  def provider
    # @user  = User.find_by_remember_token(params["token"])
    @provider = Provider.find(params["provider_id"])
    @gifts = Gift.get_provider(@provider)
    gift_hash = hash_this(@gifts, PROVIDER_REPLY) 
    respond_to do |format|
      format.json { render text: gift_hash.to_json }
    end
  end
  
  def hash_this(obj, send_fields)
    gift_hash = {}
    index = 1 
    obj.each do |g|
      
      ### >>>>>>>    remove this line of code after re-running seed.rb
      g.item_name = g.item_name.pluralize if g.quantity > 1
      ###  7/27 6:45 UTC
      
      time = g.created_at.to_time
      time_string = time_ago_in_words(time)
      
      gift_obj = g.serializable_hash only: send_fields
      gift_hash["#{index}"] = gift_obj.each_key do |key|
        value = gift_obj[key]
        gift_obj[key] = value.to_s
      end
      
      ### >>>>>>>    remove this line of code after re-running seed.rb
      gift_obj["category"] = g.item.category.to_s      
      ###  7/27 6:45 UTC

      gift_ago["time_ago"] = time_string 
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
