class Client::V3::GiftsController < MetalController

    def index
        user = User.find(params[:user_id])
        gifts = user.sent + user.received
        gifts.uniq!
        success(gifts.serialize_objs(:client))
        respond
    end


end