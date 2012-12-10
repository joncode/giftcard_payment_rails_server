class AddReceiverEmailAndShoppingCartToGifts < ActiveRecord::Migration
  def up
    add_column 	  :gifts, :receiver_email, 	:string
    add_column 	  :gifts, :shoppingCart, 	:text
    remove_column :gifts, :shopping_cart_string
  end

  def down
  	remove_column :gifts, :receiver_email
  	remove_column :gifts, :shoppingCart
  	add_column 	  :gifts, :shopping_cart_string, :string
  end
end
