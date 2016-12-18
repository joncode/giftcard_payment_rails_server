class MonthlyReportSysAlert < Alert
	include KpiQueryHelper

#   -------------

	def text_msg
		get_data
		"MONTHLY REPORT\n#{@month_name} #{@year}\n\
Gift purchases: #{@purchases} (Golf-#{@golf_p}/Food-#{@food_p})\n\
MerchantTools gifts: #{@merchant_gifts}\n\
New Merchants: #{@merchants}\n\
New Users: #{@users}\n\
Redemptions: #{@redemptions}"
	end

	def email_msg
		get_data
		"<div><h2>MONTHLY REPORT</h2><h3>#{@month_name} #{@year}</h3>\
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

	def get_data
		super since: DateTime.now.utc.beginning_of_month
	end

end