class IphoneController < AppController
  
  LOGIN_REPLY = ["first_name", "last_name" , "address" , "city" , "state" , "zip", "remember_token", "email", "phone"]
  
  GIFT_REPLY = ["giver_id", "giver_name", "item_id", "item_name", "provider_id", "provider_name", "category", "quantity", "message", "created_at", "status"]
  
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
    gifts = Gift.get_gifts(@user)
    @gifts = to_hash!(gifts) 
    
    respond_to do |format|
      format.json { render json: @gifts, only: GIFT_REPLY }
    end
  end

  def buys
    @user  = User.find_by_remember_token(params["token"])
    gifts = Gift.get_buy_history(@user)
    @gifts = to_hash!(gifts) 
    
    respond_to do |format|
      format.json { render json: @gifts, only: GIFT_REPLY }
    end
  end
  
  def activity
    @user  = User.find_by_remember_token(params["token"])
    gifts = Gift.get_activity
    @gifts = to_hash!(gifts) 
    
    respond_to do |format|
      format.json { render json: @gifts, only: GIFT_REPLY }
    end
  end
  
  def to_hash!(array)
    index = 0
    total = array.count
    hash = {}
    while index < total
      num = index + 1
      hash[num] = array[index]
      index += 1
    end
    return hash
  end
  
  private
  
    def create_user_object(data)
      obj = JSON.parse data
      obj.symbolize_keys!
      User.new(obj)
    end
  
    # def create_user_object_from_json_obj(data)
    #   worked_data = data.symbolize_keys
    #   worked_data.delete :controller
    #   worked_data.delete :action
    #   worked_data.delete :format
    #   User.new(worked_data)
    # end
end
