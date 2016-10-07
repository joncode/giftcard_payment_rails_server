class MonthlyReportSysAlert < Alert


#   -------------

	def text_msg
		get_data
		"Monthly Report\nActivity #{@month_name} #{@year}\n\
Gift purchases: #{@purchases}\n\
MerchantTools gifts: #{@merchant_gifts}\n\
New Merchants: #{@merchants}\n\
New Users: #{@users}\n\
Redemptions: #{@redemptions}"
	end

	def email_msg
		get_data
		"<div><h2>Monthly Report</h2><h3>Activity #{@month_name} #{@year}</h3>\
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
		time_period_end = DateTime.now.utc.beginning_of_month
		time_period_begin = time_period_end - 1.month
		@month_name ||= TimeGem.month_name(time_period_begin)
		@year ||= time_period_begin.year
		@purchases ||= Gift.where(cat: 300).where(created_at: [time_period_begin ... time_period_end]).count
		@merchant_gifts ||= Gift.where(cat: [200, 250]).where(created_at: [time_period_begin ... time_period_end]).count
		@merchants ||= Merchant.where(created_at: [time_period_begin ... time_period_end]).count
		@users ||= User.where(created_at: [time_period_begin ... time_period_end]).count
		@redemptions ||= Redemption.where(active: true, status:'done', created_at: [time_period_begin ... time_period_end]).count
	end

end