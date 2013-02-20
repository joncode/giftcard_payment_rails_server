module UserMailerHelper

	def list_shopping_cart(gift)
		cart = JSON.parse gift.shoppingCart
		html_string = ""
		cart.each do |item|
			str = "<p>#{item.quantity} - #{item.item_name}</p>"
			html_string << str
		end
		return html_string
	end

end