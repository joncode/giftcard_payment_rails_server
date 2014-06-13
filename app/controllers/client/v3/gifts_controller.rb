class Client::V3::GiftsController < MetalController

    def index
    	puts "\n FAEK TOkes = #{request.headers["HTTP_X_AUTH_TOKEN"]} \n"
        user = User.find(params[:user_id])
        gifts = user.sent + user.received
        gifts.uniq!
        success(gifts.serialize_objs(:client))
        respond
    end


end