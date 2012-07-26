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
      worked_data = data.symbolize_keys
      zip_code = worked_data[:zip]
      worked_data[:zip] = zip_code.to_i
      worked_data.delete :controller
      worked_data.delete :action
      worked_data.delete :format
      new_user = User.new(worked_data)
      return new_user
    end
end
