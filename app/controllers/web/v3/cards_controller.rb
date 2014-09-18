class Web::V3::CardsController < MetalController

    include CimProfile

    before_action :authenticate_web_user

    rescue_from JSON::ParserError, :with => :bad_request

    def index
        success(Card.get_cards(@current_user))
        respond
    end

    def credentials
        profile_id = get_cim_profile(@current_user)
        json       = mobile_credentials_response(profile_id)   # cim_profile concern
        success(json)
        respond
    end

    def create
        create_with            = token_params
        create_with["user_id"] = @current_user.id
        card = CardToken.build_card_token_with_hash create_with
        if card.save
            success   card.token_serialize
        else
            fail_web  fail_web_payload("incomplete_info")
            status = :bad_request
        end
        respond(status)
    end

    def destroy
        card = @current_user.cards.where(id: params[:id]).first
        if card
            destroy_card(card, @current_user)   # cim_profile concern
            success(card.id)
        else
            status = :not_found
        end

        respond(status)
    end

private

    def token_params
        params.require(:data).permit(:nickname, :token, :last_four, :brand)
    end

end