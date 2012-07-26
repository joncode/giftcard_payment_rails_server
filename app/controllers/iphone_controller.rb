class IphoneController < AppController
  
  def create_account
    @message = ""
    data = params["iphone"]
    if data.nil?
      @message = "Data not received correctly. "
    else
      @new_user = create_user_account(data)           
    end
    
    respond_to do |format|
      if !data.nil? && @new_user.save
        rtoken = @new_user.remember_token
        format.json { render text: rtoken.to_s } 
      else
        @message += " Unable to save to database"
        format.json { render text: @message.to_s }
      end
    end
  end
  
  private
  
    def create_user_account(data)
      # data_hash = JSON.parse data
      new_user = User.new
      new_user.credit_number = data["credit_number"]
      new_user.phone = data["phone"]
      new_user.email = data["email"]
      new_user.password = data["password"]
      new_user.password_confirmation = data["password_confirmation"]
      new_user.state = data["state"]
      new_user.city = data["city"]
      new_user.zip = data["zip"].to_i
      new_user.first_name = data["first_name"]
      new_user.last_name = data["last_name"]
      new_user.address = data["address"]
      return new_user
    end
end

# {"credit_number"=>"[FILTERED]", "first_name"=>"Taylor", "phone"=>"2052920078", "address"=>"200 Spooner St", "last_name"=>"Addison", "city"=>"Tuscaloosa", "email"=>"test@gmail.com", "state"=>"AL", "zip"=>"35401", "password"=>"[FILTERED]", "password_confirmation"=>"[FILTERED]", "controller"=>"iphone", "action"=>"create_account", "format"=>"json"}