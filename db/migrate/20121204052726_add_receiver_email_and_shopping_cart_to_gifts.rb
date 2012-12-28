class AddReceiverEmailAndShoppingCartToGifts < ActiveRecord::Migration
  def change
    add_column :gifts, :receiver_email, :string
    add_column :gifts, :shoppingCart, :string
  end
end
