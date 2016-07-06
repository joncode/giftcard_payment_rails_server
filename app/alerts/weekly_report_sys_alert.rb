class WeeklyReportSysAlert

	def initialize

	end

	def self.message_for target=nil
		time_period = 1.week.ago
		purchases = Gift.where(cat: 300).where('created_at > ?', time_period).count
		merchant_gifts = Gift.where(cat: [200, 250]).where('created_at > ?', time_period).count
		merchants = Merchant.where('created_at > ?', time_period).count
		users = User.where('created_at > ?', time_period).count
		"<h2>Weekly Report</h2><h3>Activity last week</h3>\
<p><ul><li>Gift purchases: #{purchases}</li>\
<li>MerchantTools gifts: #{merchant_gifts}</li>\
<li>New Merchants: #{merchants}</li>\
<li>New Users: #{users}</li>".html_safe
	end







end