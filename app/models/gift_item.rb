class GiftItem < ActiveRecord::Base
	extend MoneyHelper
	include MoneyHelper


	validates_presence_of :price, :price_cents, :quantity, :menu_item_id
	# validates_uniqueness_of :menu_item, scope: [:gift_id, :quantity, :price_cents]

#   -------------


	belongs_to :gift
	belongs_to :menu_item


#   -------------


	def self.initFromDictionary menu_item_hash
		giftItem = GiftItem.new
		giftItem.menu_item_id = menu_item_hash["item_id"]
		giftItem.price = menu_item_hash["price"]
		giftItem.price_cents = menu_item_hash["price_cents"] || currency_to_cents(menu_item_hash["price"])
		giftItem.quantity = menu_item_hash["quantity"]
		giftItem.name = menu_item_hash["item_name"]
		giftItem.detail = menu_item_hash["detail"]
		giftItem.ccy = menu_item_hash["ccy"]
		giftItem
	end

	def self.items_for_email gift
		sc 		   = JSON.parse gift.shoppingCart
		output_str = "<ul style='list-style-type:none;'>"
		sc.each do |item|

			if menu_item = MenuItem.where(id: item["item_id"]).last
				if (menu_item.name[0] == '$') && (menu_item.name.length < 5)
					item_name = "#{menu_item.name} Voucher"
				else
					item_name = menu_item.name
				end
				gift_string = "#{item['quantity']} #{item_name}"
				gift_details = "<li>" + gift_string.truncate(50) + "</li>"
			else
				gift_details = "<li>#{item['quantity']} #{item['item_name']}</li>"
			end

			output_str += gift_details
		end

		output_str += "</ul>"
		output_str
	end

#   -------------

end

# == Schema Information
#
# Table name: gift_items
#
#  id       :integer         not null, primary key
#  gift_id  :integer
#  menu_item_id  :integer
#  price    :string(255)
#  quantity :integer
#  name     :string(255)
#  detail   :text
#  ccy :string
#  price_cents :integer

