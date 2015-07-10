class AddMerchantIdToBizUserFields < ActiveRecord::Migration

	class Provider < ActiveRecord::Base; end

	def up
		set_merchant_ids
	end

	def down
		set_provider_ids
	end

	def set_provider_ids
		ps = Provider.unscoped.where.not(merchant_id: nil).each do |provider|

			merchant_id = provider.merchant_id
			provider_id = provider.id

			sql = "UPDATE debts SET owner_id = #{provider_id} WHERE owner_type = 'BizUser' AND owner_id = #{merchant_id}"
			ActiveRecord::Base.connection.execute(sql)

			sql = "UPDATE gifts SET giver_id = #{provider_id} WHERE giver_type = 'BizUser' AND giver_id = #{merchant_id}"
			ActiveRecord::Base.connection.execute(sql)

			sql = "UPDATE protos SET giver_id = #{provider_id} WHERE giver_type = 'BizUser' AND giver_id = #{merchant_id}"
			ActiveRecord::Base.connection.execute(sql)

			sql = "UPDATE campaigns SET purchaser_id = #{provider_id} WHERE purchaser_type = 'BizUser' AND purchaser_id = #{merchant_id}"
			ActiveRecord::Base.connection.execute(sql)

		end
	end

	def set_merchant_ids
		ps = Provider.unscoped.where.not(merchant_id: nil).each do |provider|

			merchant_id = provider.merchant_id
			provider_id = provider.id

			sql = "UPDATE debts SET owner_id = #{merchant_id} WHERE owner_type = 'BizUser' AND owner_id = #{provider_id}"
			ActiveRecord::Base.connection.execute(sql)

			sql = "UPDATE gifts SET giver_id = #{merchant_id} WHERE giver_type = 'BizUser' AND giver_id = #{provider_id}"
			ActiveRecord::Base.connection.execute(sql)

			sql = "UPDATE protos SET giver_id = #{merchant_id} WHERE giver_type = 'BizUser' AND giver_id = #{provider_id}"
			ActiveRecord::Base.connection.execute(sql)

			sql = "UPDATE campaigns SET purchaser_id = #{merchant_id} WHERE purchaser_type = 'BizUser' AND purchaser_id = #{provider_id}"
			ActiveRecord::Base.connection.execute(sql)

		end
	end


	def set_provider_ids_old
		ps = Provider.unscoped.where.not(merchant_id: nil).each do |provider|

			merchant_id = provider.merchant_id
			provider_id = provider.id

			Debt.where(owner_type: 'BizUser', owner_id: merchant_id).find_each do |debt|
				debt.update(owner_id: provider_id)
			end

			Gift.where(giver_type: 'BizUser', giver_id: merchant_id).find_each do |gift|
				gift.update(giver_id: provider_id)
			end

			Proto.where(giver_type: 'BizUser', giver_id: merchant_id).find_each do |proto|
				proto.update(giver_id: provider_id)
			end

			Campaign.where(purchaser_type: 'BizUser', purchaser_id: merchant_id).find_each do |camp|
				camp.update(purchaser_id: provider_id)
			end

		end
	end

	def set_merchant_ids_old
		ps = Provider.unscoped.where.not(merchant_id: nil).each do |provider|

			merchant_id = provider.merchant_id
			provider_id = provider.id

			Debt.where(owner_type: 'BizUser', owner_id: provider_id).find_each do |debt|
				debt.update(owner_id: merchant_id)
			end

			Gift.where(giver_type: 'BizUser', giver_id: provider_id).find_each do |gift|
				gift.update(giver_id: merchant_id)
			end

			Proto.where(giver_type: 'BizUser', giver_id: provider_id).find_each do |proto|
				proto.update(giver_id: merchant_id)
			end

			Campaign.where(purchaser_type: 'BizUser', purchaser_id: provider_id).find_each do |camp|
				camp.update(purchaser_id: merchant_id)
			end

		end
	end

end
