class Mdot::V2::UsersController < JsonController
    include Email
    before_action :authenticate_customer,      only: [:index, :update, :refresh, :show, :deactivate_user_social, :profile, :socials]
    before_action :authenticate_general_token, only: [:create, :reset_password]
    rescue_from JSON::ParserError, :with => :bad_request

    def index

        users_scope = if (params[:find] && !params[:find].blank?)
            ary = params[:find].split(' ')
            if ary.count == 1
                User.where(active: true).where('first_name ilike ? OR last_name ilike ?',"%#{params[:find]}%", "%#{params[:find]}%")
            elsif ary.count == 2
                User.where(active: true).where('first_name ilike ? AND last_name ilike ?',"%#{ary[0]}%", "%#{ary[1]}%")
            elsif ary.count > 2
                first_name = ary[0]
                last_name  = ary[1] + ' ' + ary[2]
                User.where(active: true).where('first_name ilike ? AND last_name ilike ?',"%#{first_name}%", "%#{last_name}%")
            else
                User.where(active: true)
            end
        else
            User.where(active: true)
        end

        users = users_scope.pluck(:id, :first_name, :last_name, :iphone_photo)

        serialized_users = users.map do |u|
            if u[3].nil?
                u[3] = BLANK_AVATAR_URL
            end
            { "user_id" => u[0] , "photo" => u[3] , "first_name" => u[1] , "last_name" => u[2]  }
        end
        success serialized_users
        respond
    end

    def profile
        success @current_user.profile_with_ids_serialize
        respond
    end

    def refresh
        success @current_user.create_serialize
        respond
    end

    def socials
        return nil  if data_not_hash?
        return nil  if hash_empty?(params["data"])

        updates = socials_user_params
        updates["primary"] = true
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
        return nil  if data_not_hash?(params["data"])
        return nil  if hash_empty?(params["data"])
        params["data"] = if params["data"].kind_of?(String)
            JSON.parse(params["data"])
        else
            params["data"]
        end

        if params["data"]["iphone_photo"] == "http://res.cloudinary.com/htaaxtzcv/image/upload/v1361898825/ezsucdxfcc7iwrztkags.jpg"
            params["data"]["iphone_photo"] = nil
        end

        if params['data']["pn_token"]
            pn_token = params['data'].delete('pn_token')
        end
        if params["pn_token"]
            pn_token = params['pn_token']
        end
        if params['data']["platform"]
            platform = params['data'].delete('platform')
        end

        user = User.new(create_user_params)
        if user.save
            user.session_token_obj =  SessionToken.create_token_obj(user, platform, pn_token)
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
        update_hsh = update_user_params

        update_hsh["primary"] = true
        if @current_user.update(update_hsh)
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
        if user_social = UserSocial.includes(:user).where(type_of: 'email', identifier: params["data"].downcase).references(:users).first
            user = user_social.user
            user.update_reset_token
            send_reset_password_email(user, params["data"])
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
        params.require(:data).permit([ "first_name" , "pn_token", "email" , "password", "password_confirmation", "last_name" ,"phone", "twitter", "facebook_id", "iphone_photo", "handle"])
    end

end
