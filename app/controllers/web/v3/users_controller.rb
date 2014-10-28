class Web::V3::UsersController < MetalCorsController

    before_action :authenticate_general
    # before_action :print_params

    def create
		user = User.new(create_user_params)
        if user.save
            user.session_token_obj =  SessionToken.create_token_obj(user, 'www', nil)
            success user.login_client_serialize
        else
        	payload = fail_web_payload("not_created_user", user.errors)
            fail_web payload
        end
        respond(status)
    end

private

    # def print_params
    #     puts "------- before filter. params are #{params.inspect}"
    # end

    def create_user_params
        params.require(:data).permit(["first_name", "email" , "password", "password_confirmation", "last_name" ,"phone", "twitter", "facebook_id", "iphone_photo", "handle"])
    end

end
