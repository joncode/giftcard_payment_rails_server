class SetMerchantIdForProvidersSocials < ActiveRecord::Migration

	class Provider < ActiveRecord::Base; end
	def up

		set_merchant_ids_from_provider_ids

		change_column :providers_socials, :provider_id, :integer, null: true

	end

	def down

		change_column :providers_socials, :provider_id, :integer, null: false

	end

	def set_merchant_ids_from_provider_ids
		ps = Provider.unscoped.where.not(merchant_id: nil).each do |provider|

			merchant_id = provider.merchant_id
			provider_id = provider.id


			sql = "UPDATE providers_socials SET merchant_id = #{merchant_id} WHERE provider_id = #{provider_id}"
			ActiveRecord::Base.connection.execute(sql)


		end
	end


end
