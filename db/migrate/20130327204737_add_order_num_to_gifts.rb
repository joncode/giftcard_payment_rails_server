class AddOrderNumToGifts < ActiveRecord::Migration
  def change
    add_column :gifts, :order_num, :string
  end
end
