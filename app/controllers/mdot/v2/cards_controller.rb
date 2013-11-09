class Mdot::V2::CardsController < JsonController
    before_filter :authenticate_customer

    def index
        success(Card.get_cards(@current_user))
        respond
    end

    def create
        data = convert_if_json

        return nil  if data_not_hash?(data)
        card_params = strong_params(data)
        return nil  if hash_empty?(card_params)

        card_params["user_id"] = @current_user.id
        card = Card.create_card_from_hash card_params

        if card.save
            success card.id
        else
            fail card
        end
        respond
    end

    def destroy
        card = @current_user.cards.where(id: params[:id]).first
        if card
            card.destroy
            success(card.id.to_s)
        else
            head 404
            return nil
        end

        respond
    end

private

    def strong_params(data_hsh)
        allowed = ["month", "number", "year", "csv", "nickname", "name"]
        new_data = data_hsh.select{ |k,v| allowed.include? k }
        if new_data.count == allowed.count
            new_data
        else
            {}
        end
    end

end