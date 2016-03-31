class AddCentsToPrices < ActiveRecord::Migration
	def change
		add_column :gift_items, :ccy,  :string, default: "USD", limit: 6
		add_column :gift_items, :price_cents,  :integer

		add_column :menu_items, :ccy, :string, default: "USD", limit: 6
		add_column :menu_items, :price_cents, :integer
		add_column :menu_items, :price_promo_cents, :integer
		# move_strings_to_cents
	end

	def move_strings_to_cents
		MenuItem.find_each do |mitem|
			if !mitem.price.blank?
				mitem.price_cents = (mitem.price.to_f.round(2) * 100).to_i
			end
			if !mitem.price_promo.blank?
				mitem.price_promo_cents = (mitem.price_promo.to_f.round(2) * 100).to_i
			end
			mitem.ccy = "USD"
			mitem.save
		end
		GiftItem.find_each do |gitem|
			if !gitem.price.blank?
				gitem.price_cents = (gitem.price.to_f.round(2) * 100).to_i
			end
			gitem.ccy = "USD"
			gitem.save
		end
	end
end
