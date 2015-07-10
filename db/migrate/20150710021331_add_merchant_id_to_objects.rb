class AddMerchantIdToObjects < ActiveRecord::Migration

	class Provider < ActiveRecord::Base; end

	def up
		add_column :gifts, :merchant_id, :integer
		add_column :bulk_emails, :merchant_id, :integer
		add_column :campaign_items, :merchant_id, :integer
		add_column :protos, :merchant_id, :integer
		add_column :sales, :merchant_id, :integer
		add_column :brands_providers, :merchant_id, :integer
		add_column :menu_strings, :merchant_id, :integer
		add_column :providers_socials, :merchant_id, :integer

		add_index :brands_providers, :merchant_id
		add_index :gifts, [:merchant_id, :created_at]
		add_index :gifts, [:merchant_id, :status]
		add_index :gifts, :merchant_id
		add_index :menu_strings, :merchant_id
		add_index :protos, :merchant_id
		add_index :providers_socials, [:merchant_id, :social_id]
		add_index :providers_socials, :merchant_id
		add_index :sales, :merchant_id

		set_merchant_ids_from_provider_ids
	end

	def down
		remove_column :gifts, :merchant_id
		remove_column :bulk_emails, :merchant_id
		remove_column :campaign_items, :merchant_id
		remove_column :protos, :merchant_id
		remove_column :sales, :merchant_id
		remove_column :brands_providers, :merchant_id
		remove_column :menu_strings, :merchant_id
	end


	def set_merchant_ids_from_provider_ids
		ps = Provider.unscoped.where.not(merchant_id: nil).each do |provider|

			merchant_id = provider.merchant_id
			provider_id = provider.id

			[:gifts, :bulk_emails, :campaign_items, :protos, :sales, :brands_providers, :menu_strings].each do |klass|
				sql = "UPDATE #{klass.to_s} SET merchant_id = #{merchant_id} WHERE provider_id = #{provider_id}"
				ActiveRecord::Base.connection.execute(sql)
			end

		end
	end

end
