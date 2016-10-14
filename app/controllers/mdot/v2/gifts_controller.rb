require 'date'

class Mdot::V2::GiftsController < JsonController
    include MoneyHelper
    before_action :authenticate_customer
    before_action :set_current_client, except: [ :index, :archive, :badge, :promo ]

    rescue_from JSON::ParserError, :with => :bad_request
    rescue_from ActiveModel::ForbiddenAttributesError, :with => :bad_request

    def index
        date_in_seconds = params[:since].present? ? params[:since].to_i : 0
        last_update     = Time.at(date_in_seconds).to_datetime

        gifts = @current_user.sent.where("updated_at > ?", last_update) + @current_user.received.where("updated_at > ?", last_update)
        gifts.uniq!
        success(gifts.serialize_objs(:client))
        respond
    end

    def archive
        give_gifts, rec_gifts  = Gift.get_archive(@current_user)
        give_ary = give_gifts.serialize_objs(:giver)
        rec_ary  = rec_gifts.serialize_objs(:receiver)
        success({"sent" => give_ary, "used" => rec_ary })
        respond
    end

    def badge
        if params[:pn_token] && params[:pn_token].length > 22
            Resque.enqueue(CreatePnTokenJob, @current_user.id, params[:pn_token], params[:platform])
        end
        gift_array  = Gift.get_gifts(@current_user)
        badge       = gift_array.count
        if badge > 0
            success({ "badge" => badge, "gifts" => gift_array.serialize_objs(:badge) })
        else
            success({ "badge" => 0 })
        end
        respond
    end

    def open  # redeption v1 && v2
        gift   = @current_user.received.where(id: params[:id]).first
        return nil if params_bad_request
        return nil if data_not_found?(gift)


        if gift.old_read(@current_client.id)
            success(gift.token)
        else
            if !gift.notifiable?
                fail "Gift #{gift.token} at #{gift.provider_name} is #{gift.status}"
            else
                fail gift
            end
            #status = :unprocessable_entity
        end
        respond(status)
    end

    def notify  # redemption v2 ONLY
        gift   = @current_user.received.where(id: params[:id]).first
        return nil if data_not_found?(gift)
        resp = Redeem.start(gift: gift, loc_id: redeem_params["loc_id"], client_id: @current_client.id, api: "mdot/v2/gifts/#{gift.id}/notify")
        if resp['success']
            gift = resp['gift']
            success({ token:  gift.token, notified_at: gift.notified_at, new_token_at: gift.new_token_at })
        else
            fail "Gift at #{gift.provider_name} cannot be redeemed"
            status = :unprocessable_entity
        end
        respond(status)
    end

    def pos_redeem
        puts "IN MDOT GIFTS _POS_REDEEM_ POS REDEEM #{params.inspect}"
        gift = Gift.includes(:merchant).find params[:id]
        if (gift.status == 'notified') && (gift.receiver_id == @current_user.id)
            if ticket_num = redeem_params["ticket_num"]
                if !gift.merchant.nil?

                    resp = Redeem.start(sync: true, gift: gift, loc_id: redeem_params['loc_id'],
                        client_id: @current_client.id, api: "mdot/v2/gifts/#{gift.id}/pos_redeem")
                    if resp['success']
                        @current_redemption = resp['redemption']
                    end
                    if @current_redemption.present?
                        ra = Redeem.apply(gift: gift, redemption: @current_redemption, ticket_num: ticket_num)
                        rc = Redeem.complete(redemption: ra['redemption'], gift: ra['gift'], pos_obj: ra['pos_obj'])
                        if !rc.kind_of?(Hash)
                            status = :bad_request
                            fail("Merchant is not active currently. Please contact support@itson.me")
                        elsif rc["success"] == true
                            status = :ok
                            success(resp["response_text"])
                        else
                            status = :ok
                            fail(rc["response_text"])
                        end
                    else
                        fail(rc["response_text"])
                    end

                    # resp = gift.pos_redeem(ticket_num, gift.merchant.pos_merchant_id, gift.merchant.tender_type_id, redeem_params['loc_id'])
                    # if !resp.kind_of?(Hash)
                    #     status = :bad_request
                    #     fail( "Merchant is currently not active please contact support@itson.me")
                    # elsif resp["success"] == true
                    #     status = :ok
                    #     success(resp["response_text"])
                    # else
                    #     status = :ok
                    #     fail(resp["response_text"])
                    # end
                else
                    status = :bad_request
                    fail( "Merchant is currently not active please contact support@itson.me")
                end
            else
                status = :bad_request
                fail( "Ticket Number not found on request")
            end
        else
            fail_message = if gift.status == 'redeemed'
                "Gift #{gift.token} at #{gift.provider_name} has already been redeemed"
            else
                "Gift #{gift.token} at #{gift.provider_name} cannot be redeemed"
            end
            fail({ err: "NOT_REDEEMABLE", msg: fail_message})
        end
        respond(status)
    end

    def redeem  # redemption v1 ONLY
        puts "IN MDOT GIFTS _REDEEM_ V1 REDEEM #{params.inspect}"
        request_server = redeem_params
        gift = @current_user.received.where(id: params[:id]).first

        if gift
            if gift.status == 'notified'
                resp = Redeem.start(sync: true, gift: gift, loc_id: redeem_params['loc_id'],
                    client_id: @current_client.id, api: "mdot/v2/gifts/#{gift.id}/redeem")
                if resp['success']
                    @current_redemption = resp['redemption']
                end
                if @current_redemption.present?
                    ra = Redeem.apply(gift: gift, redemption: @current_redemption, server: request_server)
                    rc = Redeem.complete(redemption: ra['redemption'], gift: ra['gift'], pos_obj: ra['pos_obj'])
                    if !rc.kind_of?(Hash)
                        fail "Merchant is not active currently. Please contact support@itson.me"
                    elsif rc["success"] == true
                        success({ "order_number" => rc['redemption'].token , "total" => cents_to_currency(rc['redemption'].amount),  "server" => rc['redemption'].ticket_id })
                    else
                        fail rc["response_text"]
                    end
                else
                    fail rc["response_text"]
                end

            else
                fail_message = if gift.status == 'redeemed'
                    "Gift #{gift.token} has already been redeemed"
                else
                    "Gift #{gift.token} cannot be redeemed"
                end
                status =  :unprocessable_entity
                fail fail_message
            end
        else
            fail database_error_redeem
            status = :not_found
        end
        respond(status)
    end

    def redeem_old  # redemption v1 ONLY
        puts "IN MDOT GIFTS _REDEEM_ OLD REDEEM #{params.inspect}"
        request_server = redeem_params
        gift = @current_user.received.where(id: params[:id]).first

        if gift
            if gift.status == 'notified'
                gift.redeem_gift(request_server, redeem_params['loc_id'])
                # gift.reload
                success({ "order_number" => gift.token , "total" => gift.value,  "server" => gift.server })
            else
                fail_message = if gift.status == 'redeemed'
                    "Gift #{gift.token} has already been redeemed"
                else
                    "Gift #{gift.token} cannot be redeemed"
                end
                status =  :unprocessable_entity
                fail fail_message
            end
        else
            fail database_error_redeem
            status = :not_found
        end
        respond(status)
    end

    def regift
        # {"data"=>{"message"=>"Happy happy birthday babe! Love u!",
        # "receiver"=>{"name"=>"Scott Saunders", "receiver_email"=>"vistademo@gmail.com"}}, "id"=>"361997"}
        return nil if params_bad_request
        data = regift_params

        if data["receiver"].nil? || data["receiver"].kind_of?(String)
            bad_request
            return nil
        else
            new_gift_hsh = data["receiver"]
        end

        new_gift_hsh["receiver_oauth"] = params['data']["receiver_oauth"]
        new_gift_hsh["message"]     = data["message"]
        new_gift_hsh["old_gift_id"] = params[:id]
        new_gift_hsh["origin"] = request.headers['User-Agent']
        new_gift_hsh['client_id'] = @current_client.id
        new_gift_hsh['partner_id'] = @current_client.partner_id
        new_gift_hsh['partner_type'] = @current_client.partner_type
        gift_response = GiftRegift.create(new_gift_hsh)

        if gift_response.kind_of?(Gift)
            if gift_response.id.nil?
                fail    gift_response
                if gift_response.errors.messages == {:receiver=> ["No unique receiver data. Cannot process gift. Please re-log in if this is an error."]}
                    status = :bad_request
                end
            else
                success gift_response.giver_serialize
            end
        else
            fail gift_response
            status = :forbidden
        end
        respond(status)
    end

    def create
        return nil if params_bad_request(["data", "shoppingCart"])
        return nil if nil_key_or_value(params["data"])
        return nil if nil_key_or_value(params["shoppingCart"])
        gift_hsh     = convert_if_json(params["data"])
        shoppingCart = convert_if_json(params["shoppingCart"])
        return nil if data_not_hash?(gift_hsh)
        return nil if data_not_array?(shoppingCart)


        gift_hsh = gift_params
        if promotional_gift_params? gift_hsh
            gift_response = "You cannot gift to the #{gift_hsh["receiver_name"]} account"
        else
            gift_hsh["shoppingCart"] = params["shoppingCart"]
            gift_hsh["giver"]        = @current_user
            gift_hsh["receiver_oauth"] = params['data']["receiver_oauth"]
            gift_hsh["origin"] = request.headers['User-Agent']
            gift_hsh['client_id'] = @current_client.id
            gift_hsh['partner_id'] = @current_client.partner_id
            gift_hsh['partner_type'] = @current_client.partner_type
            puts gift_hsh.inspect
            gift_response = GiftSale.create(gift_hsh)
        end


        if gift_response.kind_of?(Gift)
            if gift_response.id
                success gift_response.giver_serialize
            else
                fail    gift_response
                #status = :bad_request
            end
        else
            fail gift_response
            # status = :not_found
        end

        respond(status)
    end

    def promo
        # promo campaign keyword
        str_code = promo_params[:code]
        resp = GiftPromoCode.perform @current_user, str_code

        if resp[:status] > 0
            success resp[:data]
        else
            fail resp[:data]
        end
        respond
    end

private

    def set_current_client
        @current_client = Client.legacy_client(nil, request.headers['User-Agent'])
    end

    def promo_params
        params.require(:data).permit(:code)
    end

    def promotional_gift_params? params_hsh
        if params_hsh["receiver_id"].nil?
            false
        else
            if params_hsh["receiver_name"].match(" Staff")
                begin
                    user = User.find(params_hsh["receiver_id"])
                    if user.last_name == "Staff"
                        false
                    else
                        true
                    end
                rescue
                    true
                end
            else
                false
            end
        end
    end

    def redeem_params
        if params['server'].present?
            params.require(:server)
        elsif params["ticket_num"].present?
            params.require(:ticket_num)
        elsif params['data'].present?
            params.require(:data).permit(:server, :loc_id, :ticket_num)
        else
            {}
        end
    end

    def regift_params
        params.require(:data).permit(:message,
            receiver: [:name, :receiver_id, :email, :phone, :facebook_id, :twitter, :receiver_email, :receiver_phone],
            receiver_oauth: [:token, :secret, :network, :network_id, :handle, :photo])
    end

    def gift_params
        if params.require(:data).kind_of?(String)
            JSON.parse(params.require(:data))
        else
            params.require(:data).permit(:message, :detail, :giver_id, :giver_name,
                :value, :service, :receiver_id, :receiver_email, :facebook_id,
                :twitter, :receiver_phone, :provider_name, :receiver_name,
                :provider_id, :credit_card, :scheduled_at,
                receiver_oauth: [:token, :secret, :network, :network_id, :handle, :photo])
        end
    end

end
