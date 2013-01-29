class SessionsController < ApplicationController
  
  def new
    @text = params[:text]
    sign_out
  end
  
  def create
    user = User.find_by_email(params[:session][:email])
    password = params[:session][:password]
    if user && user.authenticate(password)
      sign_in user
      redirect_to home_path
    else
      flash[:error] = 'Invalid email/password combination'
      redirect_to "/login"
    end
  end
  
  def destroy
    sign_out
    redirect_to root_path
  end
  
end













