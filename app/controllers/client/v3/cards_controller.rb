class Client::V3::CardsController < MetalController

    def index
    	token = request.headers["HTTP_X_AUTH_TOKEN"]
    	puts "\n User Token = #{token} \n"
        user = User.find_by(remember_token: token)
        cards_ary = Card.get_cards(user)
        cards_ary.each do |c_hsh|
            c_hsh["user_id"] = user.id
        end
        success cards_ary
        respond
    end


end