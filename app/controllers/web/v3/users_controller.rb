class Web::V3::UsersController < MetalCorsController

    # before_action :authenticate_general, only: [:create]
    before_action :print_params

    def create
        authenticate_general
		user = User.new(create_user_params)
        if user.save
            success user.profile_with_ids_serialize
        else
        	payload = fail_web_payload("not_created_user", user.errors)
            fail_web payload
        end
        respond(status)
    end

private

    def print_params
        puts "------- before filter. params are #{params.inspect}"
    end

    def create_user_params
        params.require(:data).permit(["first_name", "email" , "password", "password_confirmation", "last_name" ,"phone", "twitter", "facebook_id", "iphone_photo", "handle"])
    end

end
