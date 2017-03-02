class Web::V3::CardsController < MetalCorsController

    include CimProfile

    before_action :authentication_token_required

    rescue_from JSON::ParserError, :with => :bad_request

    def index
        success(Card.get_cards(@current_user))
        respond
    end

    def create
        create_with = card_params
        create_with["user_id"] = @current_user.id

        if params[:stripe_id].blank?
            card = Card.create_card_from_hash(create_with)
        else
            create_with.delete(:number)
            create_with.delete('number')
            card = CardStripe.create_card_from_hash(create_with)
        end

        card.client = @current_client
        card.partner = @current_partner
        card.origin = "#{@current_partner.id}|#{@current_partner.name}|#{@current_client.id}|#{@current_client.name}"
        card.save
        if card.active && card.persisted?
            success card.token_serialize
        else
            puts "CARD ERROR #{card.errors.messages} - "
            fail_web fail_web_payload("not_created_card", card.error_message)
            # status = :bad_request
        end
        respond(status)
    end

    # def create_token
    #     create_with            = token_params
    #     create_with["user_id"] = @current_user.id
    #     card = CardToken.build_card_token_with_hash create_with
    #     if card.save
    #         success   card.token_serialize
    #     else
    #         fail_web  fail_web_payload("incomplete_info")
    #         status = :bad_request
    #     end
    #     respond(status)
    # end

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
        params.require(:data).permit(:nickname, :number, :brand, :csv, :month, :year, :name, :zip, :email, :stripe_user_id, :stripe_id, :last_four)
    end

end