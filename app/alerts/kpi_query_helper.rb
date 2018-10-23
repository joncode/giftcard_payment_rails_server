module KpiQueryHelper


	def get_data since:nil, between:nil
		# Default to using yesterday's data starting from midnight PST/PDT
		# (converting from UTC to PST/PDT for internal reporting becase that's where the entire company resides)
		# This uses `in_time_zone()` to account for DST, and converts back to UTC to avoid Postgre's timezone comparison issue.
		since ||= DateTime.now.in_time_zone('Pacific Time (US & Canada)').beginning_of_day.utc
		between ||= [since ... DateTime.now]

		@total_gifts ||= Gift.where(cat: 300, created_at: between)
		@purchases ||= @total_gifts.count
		@ccy_vals = {}
		CCY.keys.each do |ccy|
			@ccy_vals[ccy] = 0
		end
		@golf_p = 0
		@total_gifts.each do |gift|
			@ccy_vals[gift.ccy] += gift.original_value
			if (gift.merchant.affiliate_id == GOLFNOW_ID) || (gift.merchant_id == 458)
				@golf_p += 1
			end
		end
		@food_p ||= @purchases - @golf_p
        @merchant_gifts ||= Gift.where(cat: [200, 250], created_at: between).count
        @merchants ||= Merchant.where(created_at: between).count
        @users ||= User.where(created_at: between).count
        @redemptions ||= Redemption.where(active: true, status:'done', created_at: between).count
        @paper_certs ||= Redemption.where(active: true, r_sys: 4, status: ['pending', 'done'], created_at: between).count

        # Pull out all PVs with checks, since there's a PV created for every purchase
        pvs = PurchaseVerification.where(created_at: between).where.not(check_count: 0)
        @pv_verified = pvs.select(&:verified?).count
        @pv_lockouts = pvs.select(&:lockout?).count
        @pv_expired  = pvs.select(&:expired?).count
	end

	def text_msg name
		get_data

		purchase_str = ''
		@ccy_vals.each do |k,v|
			next if v == 0
			purchase_str += "\t#{k} Purchases: #{display_money ccy: k, cents: v, delimiter: ','}\n"
		end

		"#{name}\n#{@header}\n\
Gift Purchases: #{@purchases} (Golf-#{@golf_p}/Food-#{@food_p})\n\
#{purchase_str}\
MerchantTools gifts: #{@merchant_gifts}\n\
New Merchants: #{@merchants}\n\
New Users: #{@users}\n\
Redemptions: #{@redemptions}\n\
Paper Certs: #{@paper_certs}\n\
\n\
Purchase Verifications:\n\
* Completed: #{@pv_verified}\n\
* Lockouts: #{@pv_lockouts}\n\
* Expired: #{@pv_expired}"
	end

	def email_msg name
		get_data

		purchase_str = ''
		@ccy_vals.each do |k,v|
			next if v == 0
			purchase_str = "<li><ul>" if purchase_str.blank?
			purchase_str += "<li>#{k} Purchases: #{display_money ccy: k, cents: v, delimiter: ','}</li>"
		end
		purchase_str = "</ul></li>" unless purchase_str.blank?

		"<div><h2>#{name}</h2><h3>#{@header}</h3>\
<p><ul><li>Gift Purchases: #{@purchases} (Golf-#{@golf_p}/Food-#{@food_p})</li>\
#{purchase_str}\
<li>MerchantTools gifts: #{@merchant_gifts}</li>\
<li>New Merchants: #{@merchants}</li>\
<li>New Users: #{@users}</li>\
<li>Redemptions: #{@redemptions}</li>\
<li>Paper Certs: #{@paper_certs}</li>\
</ul></p>\
<p><ul>\
<li>Purchase Verifications:</li>\
<li>Completed: #{@pv_verified}</li>\
<li>Lockouts: #{@pv_lockouts}</li>\
<li>Expired: #{@pv_expired}</li>\
</ul></p></div>".html_safe
	end

end