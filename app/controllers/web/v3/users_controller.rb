class Web::V3::UsersController < MetalCorsController
    include Email
    before_action :authentication_no_token, only: [:create, :reset_password]
    before_action :authentication_token_required , except: [:create, :reset_password]

    def refresh
        success @current_user.login_client_serialize
        respond
    end

    def create
		user = User.new(create_user_params)
        user.client = @current_client
        user.partner = @current_partner
        if user.save
            user.session_token_obj =  SessionToken.create_token_obj(user, 'www', nil, @current_client, @current_partner)
            # @current_client.content = user --- in Resque in create_token_obj
            success user.login_client_serialize
        else
            fail_web fail_web_payload("not_created_user", user.errors)
        end
        respond(status)
    end

    def update
        user    = @current_user
        updates = update_user_params
        puts '\n'
        puts updates
        puts '\n'
        if updates["photo"]
            updates["iphone_photo"] = updates["photo"]
        end
        updates.delete("photo")
        error_hsh = {}

        if updates["birthday"].present?
            begin
                r = Date.strptime(updates["birthday"], "%m/%d/%Y")
            rescue
                if r.nil?
                    error_hsh['birthday'] = 'is invalid'
                end
            end
        end

        if updates["social"].present?
            updaters = updates["social"].select {|u| u["_id"] }
            newbies  = updates["social"].select {|u| u["net"] }

            ids = updaters.map do |social|
                social["_id"]
            end
            user_socials  = UserSocial.where(id: ids)
            updaters.each do |social|
                us = user_socials.where(id: social["_id"]).first
                unless resp = us.update(identifier: social["value"])
                    error_hsh.merge!(us.errors.messages)
                end
            end

            if error_hsh == {}
                newbies.each do |social|
                    type_of = case social["net"]
                    when 'ph'
                        "phone"
                    when 'fb'
                        "facebook_id"
                    when 'tw'
                        "twitter"
                    when 'em'
                        "email"
                    end
                    us = UserSocial.new(user_id: @current_user.id, type_of: type_of, identifier: social["value"])
                    unless us.save
                        error_hsh.merge!(us.errors.messages)
                    end
                end
            end
            updates.delete("social")
        end
        if error_hsh == {} && user.update(updates)
            success     user.login_client_serialize
        else
            error_hsh.merge!(user.errors.messages)
            fail_web    fail_web_payload("not_created_user", error_hsh)
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

    def update_user_params
        params.require(:data).permit("first_name", "last_name", "sex", "birthday", "zip", "photo", "social" => ["net", "_id", "value" ], oauth: [:token, :secret, :net, :net_id, :handle, :photo] )
    end

    def create_user_params
        params.require(:data).permit("link", "first_name", "email" , "password", "password_confirmation", "last_name" ,"phone", "twitter", "facebook_id", "iphone_photo", "handle")
    end

end
