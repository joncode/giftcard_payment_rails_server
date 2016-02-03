class MerchantsRegions < ActiveRecord::Base

	validates_presence_of :merchant_id, :region_id
	validates :merchant_id, uniqueness: { scope: [:region_id]}

	def self.create(merchant_id: m_id, region_id: r_id)
		resp = super(merchant_id: merchant_id, region_id: region_id)
		if !resp.errors.nil?
			RedisWrap.clear_merchants_caches(region_id)
			WwwHttpService.clear_merchant_cache
		end
		resp
	end

	def destroy
		sql = "DELETE FROM merchants_regions WHERE merchant_id = #{self.merchant_id} AND region_id = #{self.region_id} RETURNING *"
		resp = MerchantsRegions.find_by_sql(sql).first
		if !resp.errors.nil?
			RedisWrap.clear_merchants_caches(resp.region_id)
			WwwHttpService.clear_merchant_cache
		end
		resp
	end

end