class Web::V3::GiftsController < MetalController

    before_action :authenticate_web_user

    def index
        user_id = params[:user_id]
        if user_id && user_id != @current_user.id
            user = User.find(user_id)
        else
            user = @current_user
        end
        gifts = user.sent + user.received
        gifts.uniq!
        success(gifts.serialize_objs(:web))
        respond
    end

end
