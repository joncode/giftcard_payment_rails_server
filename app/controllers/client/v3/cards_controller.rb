class Client::V3::CardsController < MetalController

    def index
        user = User.find(params[:user_id])
        cards_ary = Card.get_cards(user)
        cards_ary.each do |c_hsh|
            c_hsh["user_id"] = user.id
        end
        success cards_ary
        respond
    end
    

end