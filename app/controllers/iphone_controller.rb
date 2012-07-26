class IphoneController < AppController
  
  LOGIN_REPLY = ["first_name", "last_name" , "address" , "city" , "state" , "zip", "remember_token", "email", "phone"]
  
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
        response = { "error" => 'Invalid email/password combination e= #{email} p= #{password}' }.to_json
      end
    end
    
    respond_to do |format|
      format.json { render text: response }
    end
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
