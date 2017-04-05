module OmnivoreUtils

	def init_with_gift gift, ticket_num, amount=nil, loc_id=nil, merchant=nil
        if !merchant.kind_of?(Merchant)
            if loc_id.to_i > 0
                merchant = Merchant.unscoped.find(loc_id)
            else
                merchant = gift.merchant
            end
        end
		new_value = amount || gift.balance
		pos_hsh = { "ticket_num" => ticket_num,
                    "gift_card_id" => gift.hex_id,
                    "pos_merchant_id" => merchant.pos_merchant_id,
                    "tender_type_id" => merchant.tender_type_id,
                    "gift_current_value" => gift.balance,
                    "value" => new_value,
                    "brand_card_ids_ary" => gift.brand_card_ids,
                    "direct_redeem" => merchant.pos_direct,
                    'ccy' => gift.ccy }
        new(pos_hsh)
	end

    def init_with_redemption redemption, ticket_num, merchant
        pos_hsh = { "ticket_num" => ticket_num,
                    "gift_card_id" => redemption.hex_id,
                    "pos_merchant_id" => merchant.pos_merchant_id,
                    "tender_type_id" => merchant.tender_type_id,
                    "gift_current_value" => redemption.gift_prev_value,
                    "value" => redemption.amount,
                    "brand_card_ids_ary" => redemption.brand_card_ids,
                    "direct_redeem" => merchant.pos_direct,
                    'ccy' => redemption.ccy }
        new(pos_hsh)
    end

#   -------------

    def location(_id)
        resp = get(:locations, _id)
        location_response resp
    end

    def locations
        resp = get(:locations)
        location_response resp
    end

    def locs_tix_down
        resp = get('locations?where=neq(health.tickets.status,"functional")')
        location_response resp
    end

    def locs_sys_down
        resp = get("locations?where=eq(health.healthy,false)")
        location_response resp
    end

    def location_response resp
        parse_response OmnivoreLocation, 'locations', resp
    end

#   -------------

    def parse_response klass, key, resp
        if resp[:status] == 1
            if resp[:data]["_embedded"] && resp[:data]["_embedded"][key]
                locations = resp[:data]["_embedded"][key]
                d = locations.map { |l| klass.new(l) }
                { status: 1, data: d }
            else
                { status: 1, data: klass.new(resp[:data]) }
            end
        else
            { status: 0, data: RestError.new(e: resp[:error], r: resp[:res]) }
        end
    end

#   -------------

    # def tickets(loc_id, next_link=nil)
    #     hsh = {}
    #     tag = "tickets"
    #     tag += next_link.split('tickets')[1] if next_link.present?
    #     resp = get(:locations, loc_id, tag)
    #     tics = resp["_embedded"]["tickets"]
    #     if tics.kind_of?(Array)
    #         hsh["tickets"] = tics.map { |t| PosTicket.new t }
    #         if resp["_links"]["next"].present?
    #             hsh["next"] = resp["_links"]["next"]["href"]
    #         end
    #         if resp["_links"]["prev"].present?
    #             hsh["prev"] = resp["_links"]["prev"]["href"]
    #         end
    #     else
    #         hsh["error"] = "Error"
    #         hsh["tickets"] = []
    #     end
    #     hsh
    # end

#   -------------

    def get resource, obj_id=nil, meth=nil
        begin
            obj_id = obj_id.present? ? (obj_id + "/") : nil
            response = RestClient.get(
                "#{OMNIVORE_V1_API_URL}/#{resource}/#{obj_id}#{meth}",
                {:content_type => :json, accept: :json, :'Api-Key' => OMNIVORE_API_KEY }
            )
            resp = JSON.parse response
            return { status: 1, data: resp }
        rescue => e
            puts "\n\OmnivoreUtils 114 Error code = #{e.inspect}\n\n"
            if e.nil?
                response = { "response_code" => "ERROR", "response_text" => 'Contact Support', "code" => 400, "data" => [] }
                return { status: 0, data: response, res: response }
            else
                return { status: 0, data: e, error: e }
            end
        end
    end
end