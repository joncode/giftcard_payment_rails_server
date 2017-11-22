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
	end


	def self.set_menu_item_bonus proto, target
		puts "[job BonusGiftSwapEvent :: set_menu_item_bonus]"
		target.update(photo: proto.bonus_photo, detail: proto.bonus_detail)
		puts "[job BonusGiftSwapEvent :: set_menu_item_bonus] target: #{target.inspect}"

		# bust the WWW menu item cache
		WwwHttpService.clear_merchant_cache
	end


	def self.set_menu_item_normal proto, target
		puts "[job BonusGiftSwapEvent :: set_menu_item_normal]"
		target.update(photo: proto.item_photo, detail: proto.item_detail)
		puts "[job BonusGiftSwapEvent :: set_menu_item_bonus] target: #{target.inspect}"

		# bust the WWW menu item cache
		WwwHttpService.clear_merchant_cache
	end

end
