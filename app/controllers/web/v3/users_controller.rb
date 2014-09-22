class Web::V3::UsersController < MetalCorsController

    # before_action :authenticate_web_general, only: [:create]

    def create
puts "---- in create, before auth"
        authenticate_web_general        
puts "---- in create, after auth. params are #{params.inspect}"
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

    def create_user_params
        params.require(:data).permit(["first_name", "email" , "password", "password_confirmation", "last_name" ,"phone", "twitter", "facebook_id", "iphone_photo", "handle"])
    end

end
