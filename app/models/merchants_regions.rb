class MerchantsRegions < ActiveRecord::Base

	def self.create(merchant_id: m_id, region_id: r_id)
		resp = super(merchant_id: merchant_id, region_id: region_id)
		if !resp.errors.nil?
			RedisWrap.clear_merchants_caches(region_id)
			WwwHttpService.clear_merchant_cache
		end
		resp
	end


end