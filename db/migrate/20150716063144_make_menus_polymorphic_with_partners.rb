class MakeMenusPolymorphicWithPartners < ActiveRecord::Migration

	def up
		add_column :menus, :owner_id, :integer
		add_column :menus, :owner_type, :string
		add_column :affiliates, :menu_id, :integer
		add_column :affiliates, :pos_merchant_id, :integer
		add_column :merchants, :menu_id, :integer
		add_column :affiliates, :promo_menu_id, :integer
		add_column :merchants, :promo_menu_id, :integer
		set_owner_type
	end

	def down
		remove_column :menus, :owner_id
		remove_column :menus, :owner_type
		remove_column :affiliates, :menu_id
		remove_column :affiliates, :pos_merchant_id
		remove_column :merchants, :menu_id
		remove_column :affiliates, :promo_menu_id
		remove_column :merchants, :promo_menu_id
	end

	def set_owner_type
		sql = "UPDATE menus SET owner_type = 'Merchant', owner_id = merchant_id , json = (SELECT menu FROM menu_strings ms WHERE ms.merchant_id = menus.merchant_id LIMIT 1)"
		ActiveRecord::Base.connection.execute(sql)

		sql = "UPDATE merchants SET menu_id = (SELECT id FROM menus ms WHERE ms.merchant_id = merchants.id AND ms.type_of = 1),  promo_menu_id = (SELECT id FROM menus ms WHERE ms.merchant_id = merchants.id AND ms.type_of = 2)"
		ActiveRecord::Base.connection.execute(sql)
	end

end


