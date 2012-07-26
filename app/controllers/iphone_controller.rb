class IphoneController < AppController
  
  def create_account
    @message = ""
    data = params["data"]

    if data.nil?
      @message = "Data not received correctly. "
    else
      @new_user = create_user_object(data)           
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
  
    def create_user_object(data)
      obj = JSON.parse data
      obj.symbolize_keys!
      User.new(obj)
    end
  
    def create_user_object_from_json_obj(data)
      worked_data = data.symbolize_keys
      worked_data.delete :controller
      worked_data.delete :action
      worked_data.delete :format
      new_user = User.new(worked_data)
      return new_user
    end
end
