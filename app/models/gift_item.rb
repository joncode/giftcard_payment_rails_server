class GiftItem < ActiveRecord::Base
  attr_accessible :gift_id, :menu_id, :name, :price, :quantity

	belongs_to :gift
	belongs_to :menu

	validates_presence_of :price, :quantity

	def self.initFromDictionary menu_item_hash

		giftItem = GiftItem.new
		# giftItem.gift_id  = gift.id
		if menu_item_hash.has_key?("id")
			giftItem.menu_id  = menu_item_hash["id"]
		else
			giftItem.menu_id  = menu_item_hash["item_id"]
		end
		giftItem.price    = menu_item_hash["price"]
		giftItem.quantity = menu_item_hash["quantity"]
		giftItem.name 	  = menu_item_hash["item_name"]

		return giftItem
	end

	def prepare_for_shoppingCart
		item_hash = self.serializable_hash only: [:menu_id, :price, :quantity, :name]
		item_hash["category"]  = self.menu.item.category
		item_hash["section"]   = self.menu.section
        item_hash["item_id"]   = item_hash["menu_id"]
        item_hash["item_name"] = item_hash["name"]
        item_hash.delete("menu_id")
        item_hash.delete("name")
        return item_hash
	end
end
