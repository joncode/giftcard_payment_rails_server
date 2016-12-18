class DailyReportSysAlert < Alert
	include KpiQueryHelper

#   -------------

	def text_msg
		get_data
		"DAILY REPORT\n#{@day}\n\
Gift purchases: #{@purchases} (Golf-#{@golf_p}/Food-#{@food_p})\n\
MerchantTools gifts: #{@merchant_gifts}\n\
New Merchants: #{@merchants}\n\
New Users: #{@users}\n\
Redemptions: #{@redemptions}"
	end

	def email_msg
		get_data
		"<div><h2>DAILY REPORT</h2><h3>#{@day}</h3>\
<p><ul><li>Gift purchases: #{@purchases} (Golf-#{@golf_p}/Food-#{@food_p})</li>\
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



end