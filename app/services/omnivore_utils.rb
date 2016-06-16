module OmnivoreUtils

	def init_with_gift gift, ticket_num, value=nil, loc_id=nil
        if loc_id.to_i > 0
            merchant = Merchant.unscoped.find(loc_id)
        else
            merchant = gift.merchant
        end
		new_value = value || gift.balance
		pos_hsh = { "ticket_num" => ticket_num,
                    "gift_card_id" => gift.obscured_id,
                    "pos_merchant_id" => merchant.pos_merchant_id,
                    "tender_type_id" => merchant.tender_type_id,
                    "value" => new_value,
                    "brand_card_ids_ary" => gift.brand_card_ids,
                    "direct_redeem" => merchant.pos_direct }
        new(pos_hsh)
	end


end