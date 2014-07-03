class Client::V3::GiftsController < MetalController

    before_action :authenticate_user

    def index
        user_id = params[:user_id].to_i

        if user_id && user_id != @current_user.id
            user = User.find(user_id)
        else
            user = @current_user
        end

        gifts = user.sent + user.received
        gifts.uniq!
        success(gifts.serialize_objs(:client))
        respond
    end

    def open
    	gift = Gift.find(params[:id])
    	if gift.receiver_id == @current_user.id && gift.status == 'open'
    		gift.update(status: 'notified')
    	end
    	success(gift.client_serialize)
    	respond
    end

end