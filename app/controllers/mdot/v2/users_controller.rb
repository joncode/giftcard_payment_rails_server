class Mdot::V2::UsersController < JsonController
    before_filter :authenticate_customer, only: [:index, :update]
    before_filter :authenticate_general_token, only: [:create, :reset_password]

    def index
        users = User.where(active: true)
        success users.serialize_objs
        respond
    end

    def create
        data = if params["data"].kind_of?(String)
            JSON.parse(params["data"])
        else
            params["data"]
        end

        if params["pn_token"] && params["pn_token"].kind_of?(String) && params["pn_token"].length > 23
            pn_token = params['pn_token']
        end

        return nil  if data_not_hash?(data)
        user_params = create_strong_param(data)
        return nil  if hash_empty?(user_params)

        user = User.new(data)
        if user.save
            user.pn_token = pn_token if pn_token
            success({"user_id" => user.id, "token" => user.remember_token})
        else
            fail    user
            status = :bad_request
        end

        respond(status)
    end

    def update
        return nil  if data_not_hash?
        user_params = update_strong_param(params["data"])
        return nil  if hash_empty?(user_params)

        if @current_user.update_attributes(user_params)
            success(@current_user.serialize)
        else
            fail    @current_user
            status = :bad_request
        end

        respond(status)
    end

    def reset_password
        return nil if data_not_string?
        if user_social = UserSocial.includes(:user).where(type_of: 'email', identifier: params["data"]).references(:users).first
            user = user_social.user
            user.update_reset_token
            success "Email is Sent , check your inbox"
        else
            fail    "#{PAGE_NAME} does not have record of that email"
            status = :not_found
        end

        respond(status)
    end

private

    def update_strong_param(data_hsh)
        allowed = [ "first_name" , "last_name",  "phone" , "email" , "sex" , "zip", "birthday", "twitter", "facebook_id"]
        data_hsh.select{ |k,v| allowed.include? k }
    end

    def create_strong_param(data_hsh)
        allowed = [ "first_name" , "email" , "password", "password_confirmation", "last_name" ,"phone", "twitter", "facebook_id", "origin", "iphone_photo", "use_photo", "handle"]
        data_hsh.select{ |k,v| allowed.include? k }
    end

end
