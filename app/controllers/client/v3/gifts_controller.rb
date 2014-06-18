class Client::V3::GiftsController < MetalController

    def index
    	token = request.headers["HTTP_X_AUTH_TOKEN"]
    	puts "\n User Token = #{token} \n"
        user = User.find_by(remember_token: token)
        gifts = user.sent + user.received
        gifts.uniq!
        success(gifts.serialize_objs(:client))
        respond
    end

    def open
        token = request.headers["HTTP_X_AUTH_TOKEN"]
    	puts "\n User Token = #{token} \n"
        user = User.find_by(remember_token: token)
    	gift = Gift.find(params[:id])
    	if gift.receiver_id == user.id && gift.status == 'open'
    		gift.update(status: 'notified')
    	end
    	success(gift.client_serialize)
    	respond
    end


end