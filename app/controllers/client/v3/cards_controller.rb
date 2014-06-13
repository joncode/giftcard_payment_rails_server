class Client::V3::CardsController < MetalController

    def index
    	puts "\n FAEK TOEK = #{request.headers["HTTP_X_AUTH_TOKEN"]} \n"
        user = User.find(params[:user_id])
        cards_ary = Card.get_cards(user)
        cards_ary.each do |c_hsh|
            c_hsh["user_id"] = user.id
        end
        success cards_ary
        respond
    end


end