class AddShoppingCartStringToGifts < ActiveRecord::Migration
  def change
    add_column :gifts, :shopping_cart_string, :string
  end
end
