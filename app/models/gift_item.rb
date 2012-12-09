class GiftItem < ActiveRecord::Base
  attr_accessible :gift_id, :menu_id, :name, :price, :quantity

	belongs_to :gift
	belongs_to :menu

	validated presence of :gift_id, :menu_id, :price, :quantity, :name

	def self.initFromDictionary hash_of_item_from_app, gift

		giftItem = GiftItem.new
		giftItem.gift_id  = gift.id
		giftItem.menu_id  = hash_of_item_from_app["menu_id"]
		giftItem.price    = hash_of_item_from_app["price"]
		giftItem.quantity = hash_of_item_from_app["quantity"]
		giftItme.name 	  = hash_of_item_from_app["name"]
		
	end
end
