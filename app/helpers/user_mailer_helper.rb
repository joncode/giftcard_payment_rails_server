module UserMailerHelper

	def list_shopping_cart(gift)
		cart = JSON.parse gift.shoppingCart
		item_ary = []
		cart.each do |item|
			item_ary << item
		end
		return item_ary
	end

end