class WeeklyReportSysAlert < Alert
	include KpiQueryHelper

#   -------------

	def text_msg
		get_data
		"WEEKLY REPORT\nWeek of #{@week_day}\n\
Gift purchases: #{@purchases} (Golf-#{@golf_p}/Food-#{@food_p})\n\
Total Amount: #{display_money ccy: 'USD', cents: @total_value}\n\
MerchantTools gifts: #{@merchant_gifts}\n\
New Merchants: #{@merchants}\n\
New Users: #{@users}\n\
Redemptions: #{@redemptions}"
	end

	def email_msg
		get_data
		"<div><h2>WEEKLY REPORT</h2><h3>Week of #{@week_day}</h3>\
<p><ul><li>Gift purchases: #{@purchases}</li>\
<li>Total Amount: #{display_money ccy: 'USD', cents: @total_value}</li>\
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
		super since: 1.week.ago
	end

end