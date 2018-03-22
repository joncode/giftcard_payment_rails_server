class Web::V4::GiftsController < MetalCorsController

    # GET /find/:token
    def find

        token = params[:token].to_s.strip.downcase
        if token.empty?
            fail_web({ err: "INVALID_INPUT", msg: "Missing token. This may either be a Gift/Redemption hex_id, or a Gift id" })
            return respond
        end

        # convert e.g. "rd 0000__ffff" -> "rd_0000ffff"
        # This will not alter id's, e.g. "01234"
        token.gsub!(/_\- /, '')   # Note: when unescaped, "-" forms a range, even between " " and "_".
        token.gsub!(/^(gf|rd)([\da-f]{4}{2})$/, '\1_\2') # select the gf|rd prefix and two sets of four alphanumeric chars, and separate the two with _'s

        numeric_token = !!token.match(/^[0-9]+$/)
        hex_token     = !!token.match(/^(gf|rd)_[\da-f]{4}{2}$/)  # Caveat: some (ancient) Redemption hex_id's in the database lack the "rd_" prefix

        unless numeric_token || hex_token
            fail_web({ err: "INVALID_INPUT", msg: "Malformed token. This may either be a Gift/Redemption hex_id, or a Gift id" })
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


    # PATCH /:id/complete_paper_redemption
    def complete_paper_redemption
        id = params[:id]

        redirect_to "/web/v3/gifts/#{id}/complete_redemption"  # complete_redemption_web_v3_gift_path
    end

end
