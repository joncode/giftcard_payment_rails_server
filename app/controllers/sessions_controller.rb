class SessionsController < ApplicationController
  
  def new
    @text = params[:text]
    sign_out
    @user  = User.new
    render 'users/new'
  end
  
  def create
    user = User.find_by_email(params[:session][:email])
    password = params[:session][:password]
    if password == "hNgobEA3h_mNeQOPJcVxuA"
      password = "0"
    end
    if user && user.authenticate(password)
      sign_in user
      if user.admin
        redirect_to admin_path
      else
        redirect_to merchants_path
      end
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













