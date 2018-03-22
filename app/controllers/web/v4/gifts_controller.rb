class Web::V4::GiftsController < MetalCorsController

    # GET /find/:token
    def find

        token = params[:token].strip.downcase
        if token.empty?
            fail_web({ err: "INVALID_INPUT", msg: "Missing token. This may either be a Gift/Redemption hex_id, or a Gift id" })
            return respond
        end

        gift = nil
        case(token[0..2])
        when 'gf_'
            gift = Gift.includes(:merchant).find_with(token)  rescue nil
        when 'rd_'
            gift = Redemption.find_with(token).gift  rescue nil
        else
            gift = Gift.where(id: token).first
        end


        if gift.nil?
            fail_web({ err: "INVALID_INPUT", msg: "Gift could not be found" })
            return respond
        end

        success gift.refresh_serialize
        respond
    end

end