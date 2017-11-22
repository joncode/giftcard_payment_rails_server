class BonusGiftSwapEvent
    @queue = :database

	def self.perform proto_id
		# we do not need set_value , the swap exists based on the value of the underlying proto
		proto = Proto.where(bonus: true, id: proto_id).first
		return  unless proto.bonus

		if proto.bonus_on?
			set_menu_item_bonus proto, proto.target
		else
			set_menu_item_normal proto, proto.target
		end

		# here is the process for busting the 3-layer menu cache system that exists
			# Layers
				# 1 - menu items are pre-compiled into menu.json column ( called via merchant.menu_string )
					# compile menu to app
					merchant = proto.merchant
					merchant.menu.compile_menu_to_app
				# 2 - menu string JSON is stored in the redis layer
					# create the new json response for menu
					cache_resp = merchant.menu_string
					# save that menu to Redis
					RedisWrap.set_menu(merchant.menu_id, cache_resp)
				# 3 - some WBG gifting pages use a cache on that layer , you must bust that
					WwwHttpService.clear_merchant_cache
	end


	def self.set_menu_item_bonus proto, target
		puts "[job BonusGiftSwapEvent :: set_menu_item_bonus]"
		target.update(photo: proto.bonus_photo, detail: proto.bonus_detail)
		puts "[job BonusGiftSwapEvent :: set_menu_item_bonus] target: #{target.inspect}"

	end


	def self.set_menu_item_normal proto, target
		puts "[job BonusGiftSwapEvent :: set_menu_item_normal]"
		target.update(photo: proto.item_photo, detail: proto.item_detail)
		puts "[job BonusGiftSwapEvent :: set_menu_item_normal] target: #{target.inspect}"
	end


end
