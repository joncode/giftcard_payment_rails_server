class Admt::V2::UsersController < JsonController

    before_filter :authenticate_admin_tools

    def update
        # we do not have the criteria for this route yet
    end

    def deactivate
        user = User.unscoped.find(params[:id])
        if user.permanently_deactivate
            success   "#{user.name} is now permanently deactivated"
        else
            fail      user.errors.full_messages
        end
        respond
    end

end
