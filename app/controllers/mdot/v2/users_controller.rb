class Mdot::V2::UsersController < JsonController
    include Email
    before_action :authenticate_customer, only: [:index, :update]
    before_action :authenticate_general_token, only: [:create, :reset_password]

    def index
        users = User.where(active: true)
        success users.serialize_objs(:get)
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
        user_param = create_strong_param(data)
        return nil  if hash_empty?(user_param)

        user = User.new(create_user_params)
        if user.save
            user.pn_token = pn_token if pn_token
            success user.create_serialize
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
            success @current_user.update_serialize
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
            send_reset_password_email(user)
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

    def update_user_params
        allowed = [ "first_name" , "last_name",  "phone" , "email" , "sex" , "zip", "birthday", "twitter", "facebook_id"]
        params.require(:data).permit(allowed)
    end

    def create_strong_param(data_hsh)
        allowed = [ "first_name" , "email" , "password", "password_confirmation", "last_name" ,"phone", "twitter", "facebook_id", "origin", "iphone_photo", "use_photo", "handle"]
        data_hsh.select{ |k,v| allowed.include? k }
    end

    def create_user_params
        allowed = [ "first_name" , "email" , "password", "password_confirmation", "last_name" ,"phone", "twitter", "facebook_id", "iphone_photo", "handle"]
        params.require(:data).permit(allowed)
    end

end
