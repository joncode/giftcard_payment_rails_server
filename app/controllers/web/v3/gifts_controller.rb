class Web::V3::GiftsController < MetalController

    before_action :authenticate_web_user

    def index
        user_id = params[:user_id]
        if user_id && user_id != @current_user.id
            user = User.find(user_id)
        else
            user = @current_user
        end
        gifts = user.sent + user.received
        gifts.uniq!
        success(gifts.serialize_objs(:web))
        respond
    end

    def create
        gift_hash = {}
        case gift_params[:rec_net]
        when "em"
            gift_hash["receiver_email"] = gift_params[:rec_net_id]
        when "ph"
            gift_hash["receiver_phone"] = gift_params[:rec_net_id]
        when "fb"
            gift_hash["receiver_oauth"] = {}
            gift_hash["receiver_oauth"]["network"] = "facebook"
            gift_hash["receiver_oauth"]["network_id"] = gift_params[:rec_net_id]
            gift_hash["receiver_oauth"]["token"]   = gift_params[:rec_token]
            gift_hash["receiver_oauth"]["photo"]   = gift_params[:rec_photo] if gift_params[:rec_photo]
        when "io"
            gift_hash["receiver_oauth"] = {}
            gift_hash["receiver_oauth"]["network"] = "itsonme"
            gift_hash["receiver_oauth"]["network_id"] = gift_params[:rec_net_id]
            gift_hash["receiver_oauth"]["photo"]   = gift_params[:rec_photo] if gift_params[:rec_photo]
        when "tw"
            gift_hash["receiver_oauth"] = {}
            gift_hash["receiver_oauth"]["network"] = "twitter"
            gift_hash["receiver_oauth"]["network_id"] = gift_params[:rec_net_id]
            gift_hash["receiver_oauth"]["token"]   = gift_params[:rec_token]
            gift_hash["receiver_oauth"]["secret"]  = gift_params[:rec_secret]
            gift_hash["receiver_oauth"]["handle"]  = gift_params[:rec_handle]
            gift_hash["receiver_oauth"]["photo"]   = gift_params[:rec_photo] if gift_params[:rec_photo]
        end
        gift_hash["shoppingCart"]  = gift_params[:items]
        gift_hash["giver"]         = @current_user
        gift_hash["credit_card"]   = gift_params[:pay_id]
        gift_hash["receiver_name"] = gift_params[:rec_name]
        gift_hash["provider_id"]   = gift_params[:loc_id]
        gift_hash["value"]         = gift_params[:value]
        gift_hash["message"]       = gift_params[:msg]
        gift = GiftSale.create(gift_hash)
        if gift.id
            success gift.giver_serialize
        else
            fail_web fail_web_payload("not_created_gift", gift.errors)
        end
        respond
    end

private

    def gift_params
        params.require(:data).permit(
            :rec_net, :rec_net_id, :rec_token, :rec_secret, :rec_handle, :rec_photo, :rec_name,
            :msg, :cat, :pay_id, :items, :value, :service,
            :loc_id, :loc_name)
    end

end
