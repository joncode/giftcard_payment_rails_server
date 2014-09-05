class Mdot::V2::CardsController < JsonController
    before_action :authenticate_customer
    rescue_from JSON::ParserError, :with => :bad_request

    def index
        success(Card.get_cards(@current_user))
        respond
    end

    def tokenize
        profile_id = @current_user.cim_profile ? @current_user.cim_profile : ""
        json = { "key" => AUTHORIZE_API_LOGIN, "token" => AUTHORIZE_TRANSACTION_KEY, "profile_id" => profile_id }
        success(json)
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

        return nil  if data_not_hash?(data)
        card_param = strong_params(data)
        return nil  if hash_empty?(card_param)

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
            card.destroy
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

    def strong_params(data_hsh)
        allowed = ["month", "number", "year", "csv", "nickname", "name"]
        new_data = data_hsh.select{ |k,v| allowed.include? k }
        if new_data.count == allowed.count
            new_data
        else
            {}
        end
    end

    def card_params
        allowed = ["month", "number", "year", "csv", "nickname", "name", "user_id", "brand"]
        if params.require(:data).kind_of?(String)
            JSON.parse(params.require(:data))
        else
            params.require(:data).permit(allowed)
        end
    end

end