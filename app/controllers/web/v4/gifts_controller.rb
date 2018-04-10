class Web::V4::GiftsController < MetalCorsController
    # I haven't cleaned up the redemption methods yet.

    before_action :authentication_token_required
    before_action :verify_token, only: [:find]
    before_action :resolve_gift, only: [:find]



    # GET /find/:token
    def find
        success @gift.refresh_serialize
        respond
    end


    def start_redemption
        # Adapted from Web::v3::Gifts#start_redemption
        puts "[api Web::v4::Gifts :: start_redemption]"
        puts " | params: #{params.inspect}"
        gift = Gift.includes(:merchant).find params[:id]

        verify_user_can_redeem_gift(gift)

        loc_id = params["data"]["loc_id"]
        amount = params["data"]["amount"]
        resp = Redeem.start_redeem(gift: gift, loc_id: loc_id, amount: amount, client_id: @current_client.id, api: "web/v4/gifts/#{gift.id}/start_redemption")
        # resp = Redeem.start_redeem(gift: g, client_id: 1, api: "test_epson")
        if resp['success']
            gift = resp['gift']
            gift.fire_after_save_queue(@current_client)
            redemption = resp['redemption'].serialize if resp['redemption'].kind_of?(Redemption)
            success({ msg: resp["response_text"], code: resp["response_code"], gift: gift.web_serialize,
                token: gift.token, redemption: redemption })
        else
            status = :ok
            fail_web({ err: resp["response_code"], msg: resp["response_text"]})
        end

        respond(status)
    end


    def complete_redemption
        # Adapted from Web::v3::Gifts#complete_redemption
        puts "[api Web::v4::Gifts :: complete_redemption]"
        puts " | params: #{params.inspect}"

        # set the data
        redemption_id = ((params["data"]["redemption_id"].to_i > 0) ? params["data"]["redemption_id"].to_i : nil)
        server_inits = params["data"]["server"]
        ticket_num = params["data"]["ticket_num"]
        qrcode = params["data"]["qrcode"]

        # amount && loc_id are on the redemption
        amount = params["data"]["amount"]
        loc_id = ((params["data"]["loc_id"].to_i > 0) ? params["data"]["loc_id"].to_i : nil)

        # find the redemption
        @current_redemption = nil
        if redemption_id.present?
            @current_redemption = Redemption.includes([:merchant, :gift]).find(redemption_id)
        else
            gift = Gift.includes(:merchant).find(params[:id])
            @current_redemption = Redemption.current_pending_redemption(gift, nil, gift.merchant.r_sys)
            if @current_redemption.nil?
                resp = Redeem.start(sync: true, gift: gift, amount: amount, loc_id: loc_id,
                    client_id: @current_client.id, api: "web/v3/gifts/#{gift.id}/complete_redemption")
                if resp['success']
                    @current_redemption = resp['redemption']
                end
            else
                # what if current pending R != amount or loc ?
            end
        end
        if @current_redemption.present? && @current_redemption.gift_id == params[:id].to_i
            gift ||= @current_redemption.gift

            verify_user_can_redeem_gift(gift)

            if gift.status != 'redeemed'
                if @current_redemption.redeemable? && @current_redemption.gift_id == gift.id

                    resp = Redeem.complete_redeem(gift: gift, redemption: @current_redemption, qr_code: qrcode, ticket_num: ticket_num, server: server_inits, client_id: @current_client.id)
                    if !resp.kind_of?(Hash)
                        status = :bad_request
                        fail_web({ err: "NOT_REDEEMABLE", msg: "Merchant is not active currently.  Please contact support@itson.me"})
                    elsif resp["success"] == true
                        gift.fire_after_save_queue(@current_client)
                        status = :ok
                        success({ msg: resp["response_text"], code: resp["response_code"], gift: gift.web_serialize,
                            token: @current_redemption.token, redemption: @current_redemption })
                    else
                        status = :ok
                        fail_web({ err: resp["response_code"], msg: resp["response_text"]})
                    end
                else
                    fail_web({ err: "NOT_REDEEMABLE", msg: "Gift at #{gift.provider_name} cannot be redeemed (B651) " })
                end
            else
                fail_web({ err: "ALREADY_REDEEMED", msg: "Gift #{gift.token} at #{gift.provider_name} has already been redeemed" })
            end
        else
            details = []
            details << "redemption_id: #{redemption_id}"
            details << "@current_redemption.present? #{@current_redemption.present?}"
            details << "r_sys: #{@current_redemption.r_sys rescue nil}"
            details << "@current_redemption.gift_id: #{@current_redemption.gift_id rescue nil}"
            details << "params[:id]: #{params[:id]}"
            details << "------ Summary: ------"
            details << "Specified Redemption does not exist"                                       if  redemption_id.present? && !@current_redemption.present?
            details << "Redemption was not created"                                                if !redemption_id.present? && !@current_redemption.present?
            details << "Gift ID mismatch (#{@current_redemption.gift_id} vs #{params[:id].to_i})"  unless @current_redemption.gift_id == params[:id].to_i
            details << "------ Inspect: ------"
            details << (@current_redemption.inspect  rescue "(@current_redemption does not exist)")
            details = details.join(" -- ")
            details = "(None)"  if details.empty?
            fail_web({ err: "NOT_REDEEMABLE", msg: "Gift at #{gift.provider_name} has a technical issue.  Please contact support at support@itson.me or on Get Help tab in app.  Details: #{details}" })
        end
        respond(status)
    end



private


    def verify_token
        @token = params[:token].to_s.strip.downcase
        if @token.empty?
            fail_web({ err: "INVALID_INPUT", msg: "Missing token. This may either be a Gift/Redemption hex_id, or a Gift id" })
            return respond
        end

        # convert e.g. "rd 0000__ffff" -> "rd_0000ffff"
        # This will not alter id's, e.g. "01234"
        @token.gsub!(/[_\- ]/, '')   # Note: Order is intentional to demostrate that, when unescaped, "-" forms a range, even between " " and "_".
        @token.gsub!(/^(gf|rd)([\da-z]{4}{2})$/, '\1_\2') # select the gf|rd prefix and two sets of four alphanumeric chars, and separate the two with _'s

        numeric_token = !!@token.match(/^[0-9]+$/)
        hex_token     = !!@token.match(/^(gf|rd)_[\da-z]{4}{2}$/)  # Caveat: some (ancient) Redemption hex_id's in the database lack the "rd_" prefix

        unless numeric_token || hex_token
            fail_web({ err: "INVALID_INPUT", msg: "Malformed token. This may either be a Gift/Redemption hex_id, or a Gift id" })
            return respond
        end

        true
    end


    def resolve_gift
        # Resolve Gift object from an Gift id, or a Gift/Redemption hex_id

        @gift = case(@token[0..2])
        when 'gf_'
            Gift.includes(:merchant).find_with(@token)  rescue nil
        when 'rd_'
            Redemption.find_with(@token).gift  rescue nil
        else
            Gift.where(id: @token).first
        end

        return true  if @gift.present?

        fail_web({ err: "INVALID_INPUT", msg: "Gift could not be found" })
        return respond
    end


    def verify_user_can_redeem_gift(gift)
        return true  if @current_user.can_redeem_gift?(gift)

        fail_web({ err: "UNAUTHORIZED", msg: "You lack sufficient permission to redeem a gift at #{gift.provider_name}" })
        respond
    end

end
