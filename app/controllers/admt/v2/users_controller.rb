class Admt::V2::UsersController < JsonController

    before_action :authenticate_admin_tools

    def update
        return nil  if data_not_hash?
        user_params = strong_param(params["data"])
        return nil  if hash_empty?(user_params)

        user = User.find(params[:id])
        if user.update(user_params)
            success "User #{user.id} updated"
        else
            fail user
        end

        respond
    end

    def deactivate
        begin
            user = User.unscoped.find(params[:id])
            if user.permanently_deactivate
                success "#{user.name} is deactivated"
            else
                fail    user
            end
        rescue
            fail    "App user not found - #{params[:id]}"
        end
        respond
    end

    def suspend
        begin
            user = User.unscoped.find(params[:id])
            if user.suspend
                if user.active == true
                    success "#{user.name} is now unsuspended"
                else
                    success "#{user.name} is now suspended"
                end
            else
                fail    user
            end
        rescue
            fail    "App user not found - #{params[:id]}"
        end
        respond
    end

    def deactivate_social
        user = User.find(params[:id])
        user_id    = params["id"]
        type_of    = params["data"]["type_of"]
        identifier = params["data"]["identifier"]
        user.deactivate_social(type_of, identifier)
        if UserSocial.unscoped.where(identifier: identifier).first.active == false
            success "#{identifier} has been deactivated"
        else
            fail "unable to deactivate #{identifier}"
        end
        respond
    end

    def deactivate_gifts
        user = User.unscoped.find(params[:id])
        total_gifts = Gift.get_user_activity(user)
        total_gifts.each do |gift|
            gift.active = false
            gift.save
        end

        if Gift.get_user_activity(user).count == 0
            success "#{user.name} all gifts deactivated"
        else
            fail    "Error in batch deactivate gifts"
        end
        respond
    end

private

    def strong_param(data_hsh)
        allowed = [ "first_name" , "last_name",  "phone" , "email", "zip", "primary" ]
        data_hsh.select{ |k,v| allowed.include? k }
    end

    def user_social_params data_hsh
        allowed = ["email", "phone", "facebook_id", "twitter", "phone"]
        data_hsh.select{ |k,v| (allowed.include?(k)) }
    end

end
