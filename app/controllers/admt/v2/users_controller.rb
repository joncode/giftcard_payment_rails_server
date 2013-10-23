class Admt::V2::UsersController < JsonController

    before_filter :authenticate_admin_tools

    def update
        return nil  if data_not_hash?
        user_params = strong_param(params["data"])
        return nil  if hash_empty?(user_params)
        user = User.where(id: params[:id]).first
        if user.kind_of?(User)
            if user.update_attributes(user_params)
                success "User #{user.id} updated"
            else
                fail user.errors.messages
            end
        else
            fail    "App user not found - #{params[:id]}"
        end

        respond
    end

    def deactivate
        begin
            user = User.unscoped.find(params[:id])
            if user.permanently_deactivate
                success "#{user.name} is deactivated"
            else
                fail    user.errors.messages
            end
        rescue
            fail    "App user not found - #{params[:id]}"
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
        allowed = [ "first_name" , "last_name",  "phone" , "email" ]
        data_hsh.select{ |k,v| allowed.include? k }
    end
end
