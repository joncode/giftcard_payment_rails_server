module OmnivoreUtils

	def init_with_gift gift, ticket_num, value=nil
		new_value = value || gift.balance
		pos_hsh = { "ticket_num" => ticket_num,
                    "gift_card_id" => gift.obscured_id,
                    "pos_merchant_id" => gift.merchant.pos_merchant_id,
                    "tender_type_id" => gift.merchant.tender_type_id,
                    "value" => new_value,
                    "brand_card_ids_ary" => gift.brand_card_ids }
        new(pos_hsh)
	end


end