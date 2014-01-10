class Admt::V2::UserSocialsController < JsonController

    before_action :authenticate_admin_tools

    def create
        return nil if data_not_hash?
        return nil if hash_empty?(user_social_params)
        user_social = UserSocial.new user_social_params
        if user_social.save
            success user_social.serializable_hash
        else
            fail    user_social
        end
        respond
    end

    def update
        user_social = UserSocial.find(params[:id])

        if user_social && user_social.update(active: false)
            success user_social.serializable_hash
        else
            fail(user_social ? user_social : data_not_found)
        end
        respond
    end

private

    def user_social_params
        params.require(:data).permit(:user_id, :type_of, :identifier, :active)
    end

end