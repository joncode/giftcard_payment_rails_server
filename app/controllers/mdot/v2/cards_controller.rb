class Mdot::V2::CardsController < JsonController
    include CimProfile

    before_action :authenticate_customer
    rescue_from JSON::ParserError, :with => :bad_request

    def index
        success(Card.get_cards(@current_user))
        respond
    end

    def create_token
        create_with            = token_params
        create_with["user_id"] = @current_user.id
        card = CardToken.build_card_token_with_hash create_with
        if card.save
            success card.token_serialize
        else
            fail card
            status = :bad_request
        end
        respond(status)
    end

    def create
        data = convert_if_json

        create_with = card_params
        create_with["user_id"] = @current_user.id
        card = Card.create_card_from_hash create_with

        if card.save
            success card.create_serialize
        else
            fail card
            #status = :bad_request
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

    def card_params
        allowed = ['month', 'number', 'year', 'csv', 'nickname', 'name', 'user_id', 'brand', 'zip']
        if params.require(:data).kind_of?(String)
            data = JSON.parse(params['data'])
            params['data'] = data
            params.require('data').permit(allowed)
        else
            params.require('data').permit(allowed)
        end
    end

end