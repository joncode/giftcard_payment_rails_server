module KpiQueryHelper


	def get_data since: 24.hours.ago, between: nil  # defaults to daily report
		if between.nil?
			between = [since ... DateTime.now]
		end

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
Paper Certs: #{@paper_certs}"
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
</ul></p></div>".html_safe
	end

end