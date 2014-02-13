class Mdot::V2::UserSocialsController < JsonController
    before_action :authenticate_customer

    def destroy
        # user_social = @current_user.user_socials.where(identifier: params["identifier"], type_of: params["type"]).first
        # if user_social
        #     user_social.deactivate
        #     success(@current_user.id)
        # else
        #     status = :not_found
        # end
        puts "====================================================================================="
        puts "=================Request made to Mdot::V2::UserSocialsController::destroy============"
        puts "====================================================================================="
        respond("please send request to users controller (01/28/14)")
    end

end