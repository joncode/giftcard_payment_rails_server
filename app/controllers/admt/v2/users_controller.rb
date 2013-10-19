class Admt::V2::UsersController < JsonController

    before_filter :authenticate_admin_tools

    def update
        # we do not have the criteria for this route yet
    end

    def deactivate
        user = User.unscoped.find(params[:id])
        user.permanently_deactivate
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

end
