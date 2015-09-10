class Section < ActiveRecord::Base
	has_many :menu_items

	def self.get_voucher(menu_id)
		section = where(menu_id: menu_id, name: 'Gift Vouchers').first
		if section.nil?
			Section.create(menu_id: menu_id, name: 'Gift Vouchers')
		else
			section
		end
	end

end