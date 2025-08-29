class SessionsController < ApplicationController

    after_filter :cross_origin_allow_header, only: [:validate_token, :change_password]

    def new
        @text = params[:text]
        sign_out
        @user  = User.new
        render 'new'
    end

    def create
        user = User.find_by(email: params[:session][:email])
        password = params[:session][:password]
        # if password == "hNgobEA3h_mNeQOPJcVxuA"
        #     password = "0"
        # end
        if user && user.authenticate(password)
            sign_in user
            # if user.admin
            #   redirect_to admin_path
            # else
              redirect_to merchants_path
            # end
        else
            flash[:error] = 'Invalid email/password combination'
            redirect_to "/signin"
        end
    end

    def destroy
      sign_out
      redirect_to root_path
    end

    #########  FORGOT PASSWORD METHODS

    def forgot_password
        puts "IN RESET PASSWORD in SESSION"
        @user = User.new
        @progress = 1
        if params[:user] && params[:user].has_key?("email")
            email = params[:user]["email"]
            if user = User.find_by(email: email)
                @progress = 2
                user.update_reset_token
                Resque.enqueue(EmailJob, 'reset_password', user.id, {})
            else
                flash[:error] = "Cannot Find Account With Email : #{email}" if !email.blank?
            end
        elsif params[:reset_token]
            user = User.find_by(reset_token: params[:reset_token])
            if user
                if Time.now - 1.day <= user.reset_token_sent_at
                    @user = user
                    return render 'enter_new_password'
                end
            end
            @progress = 3
        end
    end

    def validate_token
        response_hash = {}
        if token = params[:reset_token] #&& request.format == :json
            user = User.find_by(reset_token: token)

            if user
                if Time.now - 3.days <= user.reset_token_sent_at
                    response_hash["success"] = "Valid token |#{(NUMBER_ID + user.id)}"
                else
                    response_hash["success"] = "Expired Token |0"
                end
            else
                response_hash["success"]     = "Invalid Token |0"
            end
        else
            response_hash["error"]           = "Data not received"
        end
        request.format = :json
        respond_to do |format|
            format.json { render json: response_hash }
        end
    end

    def change_password
        # get the user for the user id - number
        response_hash = {}
        user_id = params["id"].to_i - NUMBER_ID
        if user_id < 1
            # failed attempt
            response_hash["error"] = "Could not Identify User - Please re-try forgot password"
        else
            begin
                user = User.find(user_id)
                        # confirm that the reset token is proper for the user_id and not expired
                if user.reset_token == params[:reset_token]
                            # check that you have received the password and password_conf
                    if validate_params(params)
                            # update the user object and save
                        user.password = params["password"]
                        user.password_confirmation = params["password_confirmation"]
                        if user.save
                            response_hash["success"] = "Password Update Successful!"
                        else
                            response_hash["error_server"] = user.errors.messages
                        end
                    else
                        # return that the form did not validate data
                        response_hash["error"] = "Passwords are invalid or do not match"
                    end
                else
                    # the reset token is invalid
                    response_hash["success"] = "Invalid Token |0"
                end
            rescue
                response_hash["error"] = "Could not Identify User - Please re-try forgot password"
            end
        end
        respond_to do |format|
            format.json { render json: response_hash }
        end

    end

    def enter_new_password
        user_params = params[:user]
        if !validate_params(user_params)
            @user           = User.find_by(reset_token: params[:reset_token])
            flash[:notice]  = nil
            flash[:error]   = "Password & Confirmation must be atleast 6 letters"
        else
            @message = nil
            if user_params[:password] != user_params[:password_confirmation]
                @user           = User.find_by(reset_token: params[:reset_token])
                flash[:error]   = "Your Passwords do not match. Try again."
                flash[:notice]  = "Password & Confirmation must be atleast 6 letters"
            else
                user = User.find_by(reset_token: params[:reset_token])
                user.password = user_params[:password]
                user.password_confirmation = user_params[:password_confirmation]
                user.save
                flash[:notice] = "Password saved successfully."
                flash[:error]  = nil
                sign_in user
                return redirect_to admin_path
            end
        end
    end

    private

    def validate_params user_params
        if user_params.kind_of? Hash
            if user_params["password"].nil? || user_params["password_confirmation"].nil?
                return false
            elsif user_params["password"].length < 6 || user_params["password_confirmation"].length < 6
                return false
            end
            return true
        else
            return false
        end
    end

    def cross_origin_allow_header
        headers['Access-Control-Allow-Origin'] = "*"
        headers['Access-Control-Request-Method'] = '*'
    end

end













