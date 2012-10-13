class AddSaleIdToGifts < ActiveRecord::Migration
  def change
    add_column :gifts, :sale_id, :integer
  end
end
