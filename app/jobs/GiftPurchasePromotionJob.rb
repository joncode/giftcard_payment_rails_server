class GiftPurchasePromotionJob


# [{"detail"=>"Golf cart is included, valid anytime!\r\n", "price"=>"51", "photo"=>"https://res.cloudinary.com/drinkboard/image/upload/v1469130346/bcguk0ohnwb3eehbtuht.jpg",
 # "pos_item_id"=>"", "ccy"=>"USD", "price_cents"=>5100, "item_id"=>6406, "item_name"=>"18 Holes of Golf", "quantity"=>2, "price_promo"=>"51", "price_promo_cents"=>5100, "section"=>"Gifting Menu"}]

	def self.perform gift_or_gift_id
		gift = nil
		if gift_or_gift_id.class == Gift
    		gift = gift_or_gift_id
    	else
    		gift = Gift.includes(:giver).find(gift_or_gift_id)
    	end
    	return if gift.nil?
		return if gift.cat != 300

		gift.cart.each do |mhsh|

			_mid = mhsh['item_id']
			_quantity = mhsh['quantity'] || 1
			promo_items = Proto.where(active: true, live: true, bonus: true, target_item_id: _mid) || []

			unless promo_items.empty?

				promo_items.each do |proto|

					_quantity.to_i.times do
						pj = ProtoJoin.create_with_proto_and_rec(proto, gift.giver)
						if pj.persisted?
							gift = GiftProtoJoin.create({ 'proto' => proto, 'proto_join' => pj})
						else
							# proto join save failed
							puts "Failed Bonus Gift Card - 500 Internal - #{pj.errors.messages}"
						end
					end

				end

			end

		end

	end

end


__END__

#-----------------------

Gift.rb


#-----------------------

Proto.rb


	# these protos cannot limit user amounts yet



#-----------------------

PromoItem.rb

	add_index :menu_item_id

	:menu_item_id integer
	:proto_id integer
	:photo_url string
	:detail string
	:active boolean
	:status  [:live, :stop]
	:start_at datetime
	:end_at datetime



#-----------------------


__END__




Gift is created thru the API the normal way

gift_created_event

	spin off a job to check for promos
	pull the promo item up and generate a gift for it
	done



remove the menu item for another updated menu item ?

	is this another status of menu item ?
	how does this turn off and on ?



