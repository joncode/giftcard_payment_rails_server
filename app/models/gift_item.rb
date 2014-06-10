class GiftItem < ActiveRecord::Base

	belongs_to :gift

	validates_presence_of :price, :quantity, :menu_id

	def self.initFromDictionary menu_item_hash
		giftItem = GiftItem.new
		giftItem.menu_id  = menu_item_hash["item_id"]
		giftItem.price    = menu_item_hash["price"]
		giftItem.quantity = menu_item_hash["quantity"]
		giftItem.name 	  = menu_item_hash["item_name"]
		giftItem.detail   = menu_item_hash["detail"]
		giftItem
	end

	def prepare_for_shoppingCart
		item_hash = self.serializable_hash only: [ :quantity, :name, :detail]
        item_hash["item_id"]   = self.menu_id
        item_hash["item_name"] = self.name
        item_hash
	end

	def self.items_for_email gift
		sc 		   = JSON.parse gift.shoppingCart
		output_str = "<ul style='list-style-type:none;>"
		sc.each do |item|
			if gift.provider.name == "Electric Factory"
				gift_details = "<li>#{item["quantity"]} tickets - #{item["item_name"]}</li>"
			else
				gift_details = "<li>#{item["quantity"]} #{item["item_name"]}</li>"
			end
			output_str += gift_details
		end
		output_str += "</ul>"
		output_str
	end
end

# == Schema Information
#
# Table name: gift_items
#
#  id       :integer         not null, primary key
#  gift_id  :integer
#  menu_id  :integer
#  price    :string(255)
#  quantity :integer
#  name     :string(255)
#  detail   :text
#

