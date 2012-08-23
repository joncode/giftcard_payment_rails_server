class SessionsController < ApplicationController
  
  def new
    @text = params[:text]
  end
  
  def create
    transfer = false
    if params[:page] == 'development'
      user = User.find_by_email(params[:email])
      case params[:email]
      when 'test@test.com'
        password = 'testtest'
      when 'jb@jb.com'
        password = 'jessjess'
      when 'gj@gj.com'
        password = 'johnjohn'
      when 'fl@fl.com'
        password = 'fredfred'
      when 'jp@jp.com'
        password = 'janejane'
      else
        transfer = true
      end  
    else
      user = User.find_by_email(params[:session][:email])
      password = params[:session][:password]
    end
    if user && user.authenticate(password)
      # add provider to user
      add_provider_to_user(user) if user.provider_id.empty?
      sign_in user
      redirect_to home_path
    else
      flash[:error] = 'Invalid email/password combination' if !transfer
      render 'new'
    end
  end
  
  def destroy
    sign_out
    redirect_to home_path
  end
  
  private
  
    def add_provider_to_user(user)
      # search providers for user_id
      provider_array = Provider.where(:user_id => user.id)
      # get the provider_id's
      # make an array of provider id's
      if !provider_array.empty?
        provider_ids = array_of_ids(provider_array)     
        user.update_attributes(:provider_id => provider_ids, :server_code => "0000")
        # update user to have provider_id in attributes
      end
    end
    
    def array_of_ids(provider_array)
      ids = []
      provider_array.each do |p|
        p_id = p.id
        ids << p_id
      end
      return ids
    end
  

end













