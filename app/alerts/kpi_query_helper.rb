module KpiQueryHelper


	def get_data since: 24.hours.ago   # defaults to daily report
		@day = TimeGem.dt_to_s(since)
		@total_gifts ||= Gift.where(cat: 300).where('created_at > ?', since)
		@purchases ||= @total_gifts.count


		@total_value = 0
		@golf_p = 0
		@total_gifts.each do |gift|
			@total_value += gift.value_cents
			if (gift.merchant.affiliate_id == GOLFNOW_ID) || (gift.merchant_id == 458)
				@golf_p += 1
			end
		end
		@food_p ||= @purchases - @golf_p


		@merchant_gifts ||= Gift.where(cat: [200, 250]).where('created_at > ?', since).count
		@merchants ||= Merchant.where('created_at > ?', since).count
		@users ||= User.where('created_at > ?', since).count
		@redemptions ||= Redemption.where(active: true, status:'done').where('created_at > ?', since).count
		@paper_certs ||= Redemption.where(active: true, r_sys: 4, status:['pending', 'done']).where('created_at > ?', since).count
	end




end