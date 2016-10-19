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
		if table_rows.length == 0
			return "<h3>ItsOnMe Golf Course Additions Report</h3><div><hr /><p>No new golf courses this week</p></div>"
		end
		top_html = "<h3>ItsOnMe Golf Course Additions Report</h3><div><hr />"


		bottom_html = "</div>"

		(top_html + table_rows + bottom_html).html_safe
	end

	def msg
		email_msg
	end

#   -------------

	def get_data
		# @merchant_ids = { <merchant_id> => <merchant_object>, ... }
		@merchant_ids ||= get_merchant_ids
		return "" if !@merchant_ids.kind_of?(Hash) || @merchant_ids.keys.length == 0
		email_str = ""
		@merchant_ids.each do |k,v|
			m = v
			cs = m.clients
			gn_str = ""
			ga_str = ""
			cs.each do |client|
				type = ClientUrlMatcher.gen_type(client.url_name)
				case type
				when :golf_now
					gnc_url = client.url_name
					gn_str = "<li style='color:blue;'>GolfNow URL</li><li>- <span style='color:blue;'>#{gnc_url}</span></li>"
				when :golf_advisor
					gac_url = client.url_name
					ga_str = "<li style='color:green;'>Golf Advisor URL</li><li>- <span style='color:green;'>#{gac_url}</span></li>"
				end
			end
			if gn_str.blank? && ga_str.blank?
				gn_str = "<li style='color:red;'>No URLs</li>"
			end
			email_str += "<ul style='list-style: none;'><li>Golf Course: <span>#{m.name}</span><span>FID-#{m.building_id}</li>\
<li>Website: <span>#{m.website}</span></li>#{gn_str}#{ga_str}</ul><hr />"
		end
		email_str
	end

#   -------------


	def get_merchant_ids
		golf_now_id = Rails.env.staging? ? 28 : 31
		golfnow = Affiliate.find golf_now_id
		# find all the merchants for golf now
		# exclude all the merchants that are not live
		ms = Merchant.where(paused: false, live: true, active: true, affiliate_id: golf_now_id)
		# look thru each merchant for clients with 0 clicks
		# look thru those clients for ones that are less than a week old
		email_merchant_ids = {}
		ms.each do |m|
			tt = 1.week.ago
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