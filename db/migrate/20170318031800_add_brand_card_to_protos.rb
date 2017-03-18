class AddBrandCardToProtos < ActiveRecord::Migration
  def change
    add_column :protos, :brand_card, :boolean, default: false
  end
end
