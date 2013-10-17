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

end
