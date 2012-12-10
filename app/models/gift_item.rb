class GiftItem < ActiveRecord::Base
  attr_accessible :gift_id, :menu_id, :name, :price, :quantity

	belongs_to :gift
	belongs_to :menu

	validates_presence_of :price, :quantity

	def self.initFromDictionary menu_item_hash

		giftItem = GiftItem.new
		# giftItem.gift_id  = gift.id
		giftItem.menu_id  = menu_item_hash["id"]
		giftItem.price    = menu_item_hash["price"]
		giftItem.quantity = menu_item_hash["quantity"]
		giftItem.name 	  = menu_item_hash["item_name"]

		return giftItem
	end

	def prepare_for_shoppingCart
		item_hash = self.serializable_hash only: [:menu_id, :price, :quantity, :name, :id]
        item_hash["gift_item_id"] = item_hash["id"]
        item_hash.delete("id")
        return item_hash
	end
end
