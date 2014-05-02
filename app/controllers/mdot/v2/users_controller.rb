class Mdot::V2::UsersController < JsonController
    include Email
    before_action :authenticate_customer,      only: [:index, :update, :show, :deactivate_user_social, :profile, :socials]
    before_action :authenticate_general_token, only: [:create, :reset_password]
    rescue_from JSON::ParserError, :with => :bad_request

    def index
        users = User.where(active: true)
        success users.serialize_objs(:get)
        respond
    end

    def profile
        success @current_user.profile_with_ids_serialize
        respond
    end

    def socials
        return nil  if data_not_hash?
        return nil  if hash_empty?(params["data"])

        updates = socials_user_params

        if updates["social"].present?
            ids = updates["social"].map do |social|
                social["_id"]
            end
            user_socials  = UserSocial.where(id: ids)
            updates["social"].each do |social|
                us = user_socials.where(id: social["_id"]).first
                us.update(identifier: social["value"])
            end
            updates.delete("social")
        end

        if @current_user.update(updates)
            success @current_user.profile_with_ids_serialize
        else
            fail    @current_user
        end

        respond(status)
    end

    def show
        if (params[:id] == 'me') || (@current_user.id == params[:id].to_i)
            # do app user serialize
            success @current_user.profile_serialize
        else
            other_user = User.find params[:id]
            # do other user serialize
            success other_user.get_other_serialize
        end

        respond
    end

    def create
        params["data"] = if params["data"].kind_of?(String)
            JSON.parse(params["data"])
        else
            params["data"]
        end

        if params["pn_token"] && params["pn_token"].kind_of?(String) && params["pn_token"].length > 23
            pn_token = params['pn_token']
        end

        return nil  if data_not_hash?(params["data"])
        # user_param = create_strong_param(data)
        return nil  if hash_empty?(params["data"])

        user = User.new(create_user_params)
        if user.save
            user.pn_token = pn_token if pn_token
            success user.create_serialize
        else
            fail    user
            #status = :bad_request
        end

        respond(status)
    end

    def update
        return nil  if data_not_hash?
        # user_params = update_strong_param(params["data"])
        return nil  if hash_empty?(params["data"])

        if @current_user.update(update_user_params)
            success @current_user.update_serialize
        else
            fail    @current_user
            #status = :bad_request
        end

        respond(status)
    end

    def deactivate_user_social
        user_socials = UserSocial.where(user_id: @current_user.id, active: true)
        if params["type"] == "email" && user_socials.where(type_of: "email").count < 2
            fail "cannot deactivate last email on account"
            #status = :bad_request
        elsif user_socials.where(user_id: @current_user.id, type_of: params["type"], identifier: params["identifier"]).present?
            @current_user.deactivate_social(params["type"], params["identifier"])
            success(@current_user.id)
        else
            fail "couldn't find #{params["type"]} #{params["identifier"]}"
            status = :not_found
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

    def socials_user_params
        params.require(:data).permit( :first_name , :last_name, :sex , :zip, :birthday, social: [ :_id, :value ] )
    end

    def update_user_params
        params.require(:data).permit([ "first_name" , "last_name",  "phone" , "email" , "sex" , "zip", "birthday", "twitter", "facebook_id"])
    end

    def create_user_params
        params.require(:data).permit([ "first_name" , "email" , "password", "password_confirmation", "last_name" ,"phone", "twitter", "facebook_id", "iphone_photo", "handle"])
    end

end
