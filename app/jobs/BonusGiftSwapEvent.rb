class BonusGiftSwapEvent

    @queue = :database

	def self.perform proto_id

		# we do not need set_value , the swap exists based on the value of the underlying proto

		proto = Proto.where(bonus: true, id: proto_id).first
		if proto.bonus
			if target = proto.target

					# do the swap

				if proto.bonus_on?
					set_menu_item_bonus proto, target
				else
					set_menu_item_normal proto, target
				end
			end
		end

	end


	def set_menu_item_bonus proto, target
		target.update(photo: proto.bonus_photo, detail: proto.bonus_detail)
		# bust the WWW menu item cache
		WwwHttpService.clear_merchant_cache
	end

	def set_menu_item_normal proto, target
		target.update(photo: proto.item_photo, detail: proto.item_detail)
		# bust the WWW menu item cache
		WwwHttpService.clear_merchant_cache
	end


end