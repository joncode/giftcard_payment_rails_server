class AddBrandCardToGifts < ActiveRecord::Migration
  def change
  	add_column :gifts, :brand_card, :boolean, default: false
  	add_column :campaign_items, :brand_card, :boolean, default: false
  end
end
