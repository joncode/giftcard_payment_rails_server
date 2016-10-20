class WeeklyReportSysAlert < Alert


#   -------------

	def text_msg
		get_data
		"WEEKLY REPORT\nWeek of #{@week_day}\n\
Gift purchases: #{@purchases}\n\
MerchantTools gifts: #{@merchant_gifts}\n\
New Merchants: #{@merchants}\n\
New Users: #{@users}\n\
Redemptions: #{@redemptions}"
	end

	def email_msg
		get_data
		"<div><h2>WEEKLY REPORT</h2><h3>Week of #{@week_day}</h3>\
<p><ul><li>Gift purchases: #{@purchases}</li>\
<li>MerchantTools gifts: #{@merchant_gifts}</li>\
<li>New Merchants: #{@merchants}</li>\
<li>New Users: #{@users}</li>\
<li>Redemptions: #{@redemptions}</li>\
</ul></p></div>".html_safe
	end

	def msg
		text_msg
	end

#   -------------

	def get_data
		time_period = 1.week.ago
		@week_day = TimeGem.dt_to_s(time_period)
		@purchases ||= Gift.where(cat: 300).where('created_at > ?', time_period).count
		@merchant_gifts ||= Gift.where(cat: [200, 250]).where('created_at > ?', time_period).count
		@merchants ||= Merchant.where('created_at > ?', time_period).count
		@users ||= User.where('created_at > ?', time_period).count
		@redemptions ||= Redemption.where(active: true, status:'done').where('created_at > ?', time_period).count
	end

end