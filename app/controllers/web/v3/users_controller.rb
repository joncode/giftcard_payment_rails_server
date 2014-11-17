class Web::V3::UsersController < MetalCorsController

    before_action :authenticate_general, only: [:create]
    before_action :authenticate_user , except: [:create]

    def create
		user = User.new(create_user_params)
        if user.save
            user.session_token_obj =  SessionToken.create_token_obj(user, 'www', nil)
            success user.login_client_serialize
        else
            fail_web fail_web_payload("not_created_user", user.errors)
        end
        respond(status)
    end

    def update
        user    = @current_user
        updates = update_user_params
        if updates["photo"]
            updates["iphone_photo"] = updates["photo"]
        end
        updates.delete("photo")
        error_hsh = {}

        # if updates["birthday"].present?
        #     updates["birthday"] = switch_month_and_days(updates["birthday"])
        # end

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

private

    def switch_month_and_days birthday
        bday = birthday
        if birthday.kind_of? String
            if !birthday.empty?
                begin
                    bday = Date.strptime(birthday, "%d/%m/%Y")
                rescue
                    ""
                end
            end
        end
        if bday.kind_of? Date
            m = bday.month
            d = bday.day
            y = bday.year
            "#{m}/#{d}/#{y}"
        else
            bday
        end
    end

    def update_user_params
        params.require(:data).permit("first_name", "last_name", "sex", "birthday", "zip", "photo", "social" => ["net", "_id", "value" ] )
    end

    def create_user_params
        params.require(:data).permit("first_name", "email" , "password", "password_confirmation", "last_name" ,"phone", "twitter", "facebook_id", "iphone_photo", "handle")
    end

end
