class MenuItem < ActiveRecord::Base
	belongs_to :section
	belongs_to :menu

	def self.get_voucher_for_amount(menu_id, amount='40')
		voucher_section = Section.get_voucher(menu_id)
		item = where(price: amount.to_s, section_id: voucher_section.id).first
		if item.nil?
			MenuItem.create(price: amount.to_s,
				menu_id: menu_id,
				section_id: voucher_section.id,
				name: "$#{amount.to_s} Gift Voucher",
				detail: "The entire gift amount must be used at one time. Unused portions of this gift cannot be saved, transferred, or redeemed for cash.",
				standard: false,
				promo: false
			)
		else
			item
		end
	end

    def serialize_to_app(quantity=nil)
        item_hash = self.serializable_hash only: [ :photo, :detail, :price, :price_promo, :pos_item_id ]
        item_hash["item_id"]   = self.id
        item_hash["item_name"] = self.name
        if quantity.present?
            item_hash['quantity'] = quantity
        end
        return item_hash
    end

end
# == Schema Information
#
# Table name: menu_items
#
#  id          :integer         not null, primary key
#  name        :string(255)
#  section_id  :integer
#  menu_id     :integer
#  detail      :text
#  price       :string(255)
#  photo       :string(255)
#  position    :integer
#  active      :boolean         default(TRUE)
#  price_promo :string(255)
#  standard    :boolean         default(FALSE)
#  promo       :boolean         default(FALSE)
#  created_at  :datetime
#  updated_at  :datetime
#

