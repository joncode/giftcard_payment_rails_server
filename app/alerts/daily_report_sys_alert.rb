class DailyReportSysAlert

	def initialize
	end

	def self.message_for target=nil, network=nil
		time_period = 24.hours.ago
		purchases = Gift.where(cat: 300).where('created_at > ?', time_period).count
		merchant_gifts = Gift.where(cat: [200, 250]).where('created_at > ?', time_period).count
		merchants = Merchant.where('created_at > ?', time_period).count
		users = User.where('created_at > ?', time_period).count
		if network == 'email'
			"<div><h2>Daily Report</h2><h3>Activity yesterday</h3>\
<p><ul><li>Gift purchases: #{purchases}</li>\
<li>MerchantTools gifts: #{merchant_gifts}</li>\
<li>New Merchants: #{merchants}</li>\
<li>New Users: #{users}</li></ul></p></div>".html_safe
		else
			"Daily Report\nActivity yesterday\n\
Gift purchases: #{purchases}\n\
MerchantTools gifts: #{merchant_gifts}\n\
New Merchants: #{merchants}\n\
New Users: #{users}"
		end
	end







end