class NewClientsWeeklySysAlert < Alert

	# description:
	# find new live merchants and send their client urls to golf now affiliate
		# list merchants
		# list clients per merchants that are

	attr_accessor :merchant_ids

#   -------------

	def text_msg
		email_msg
	end

	def email_msg
		table_rows = get_data
		return nil if table_rows.length == 0
		top_html = "<h3>This week's live GolfNow / ItsOnMe Golf Courses</h3><div><hr />"


		bottom_html = "</div>"

		(top_html + table_rows + bottom_html).html_safe
	end

	def msg
		email_msg
	end

#   -------------

	def get_data
		@merchant_ids ||= get_merchant_ids
		return "" if !@merchant_ids.kind_of?(Hash) || @merchant_ids.keys.length == 0
		email_str = ""
		@merchant_ids.each do |k,v|
			m = v
			cs = m.clients
			gnc = nil
			gac = nil
			cs.each do |client|
				if client.url_name.match(/_gnow/)
					gnc = client
				elsif client.url_name.match(/_menu_ga/)
					gac = client
				end
			end
			email_str += "<ul style='list-style: none;'>\
<li>Golf Course: <span>#{m.name}</span></li>\
<li>Website: <span>#{m.website}</span></li>\
<li style='color:blue;'>GolfNow URL</li>\
<li>- <span style='color:blue;'>#{gnc.url_name}</span></li>\
<li style='color:green;'>Golf Advisor URL</li>\
<li>- <span style='color:green;'>#{gac.url_name}</span></li>\
</ul><hr />"
		end
		email_str
	end

#   -------------


	def get_merchant_ids
		golf_now_id = Rails.env.staging? ? 28 : 31
		golfnow = Affiliate.find golf_now_id
		# find all the merchants for golf now
		# exclude all the merchants that are not live
		ms = Merchant.where(paused: false, live: true, affiliate_id: golf_now_id)
		# look thru each merchant for clients with 0 clicks
		# look thru those clients for ones that are less than a week old
		email_merchant_ids = {}
		ms.each do |m|
			tt = 2.weeks.ago
			cs = m.clients
			cs.each do |client|
				if client.clicks == 0 && client.created_at > tt
					email_merchant_ids[m.id] = m
					break
				end
			end
		end
		# format those into an email and send
		email_merchant_ids
	end

end