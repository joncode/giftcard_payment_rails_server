module UserMailerHelper

	def list_shopping_cart(gift)
		JSON.parse gift.shoppingCart
	end

end