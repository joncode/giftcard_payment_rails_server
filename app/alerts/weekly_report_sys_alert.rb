class WeeklyReportSysAlert < Alert


#   -------------

	def text_msg
		get_data
		"Weekly Report\nActivity last week\n\
Gift purchases: #{@purchases}\n\
MerchantTools gifts: #{@merchant_gifts}\n\
New Merchants: #{@merchants}\n\
New Users: #{@users}"
	end

	def email_msg
		get_data
		"<div><h2>Weekly Report</h2><h3>Activity last week</h3>\
<p><ul><li>Gift purchases: #{@purchases}</li>\
<li>MerchantTools gifts: #{@merchant_gifts}</li>\
<li>New Merchants: #{@merchants}</li>\
<li>New Users: #{@users}</li></ul></p></div>".html_safe
	end

	def msg
		text_msg
	end

#   -------------

	def get_data
		time_period = 1.week.ago
		@purchases ||= Gift.where(cat: 300).where('created_at > ?', time_period).count
		@merchant_gifts ||= Gift.where(cat: [200, 250]).where('created_at > ?', time_period).count
		@merchants ||= Merchant.where('created_at > ?', time_period).count
		@users ||= User.where('created_at > ?', time_period).count
	end

end