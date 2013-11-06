class Mdot::V2::UsersController < JsonController
    before_filter :authenticate_customer

    def index
        users = User.where(active: true)
        success users.serialize_objs
        respond
    end

    def create
        respond
    end

    def update
        return nil  if data_not_hash?
        user_params = strong_param(params["data"])
        return nil  if hash_empty?(user_params)

        if @current_user.update_attributes(user_params)
            success(@current_user.serialize)
        else
            fail    @current_user
        end

        respond
    end

    def reset_password
        respond
    end

private

    def strong_param(data_hsh)
        allowed = [ "first_name" , "last_name",  "phone" , "email" , "sex" , "zip", "birthday", "twitter", "facebook_id"]
        data_hsh.select{ |k,v| allowed.include? k }
    end

end
