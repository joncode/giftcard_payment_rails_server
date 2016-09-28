class ClientUrlMatcher

# GOLFNOW_COM = 331
# GOLFADVISOR_COM = 13326
# GOLFCOURSE_WEBSITE = 74
# GOLFFACEBOOK_TAB = 62

	class << self

		def gen_type client_url_name
			type = specific_type(client_url_name)
			type.to_s.gsub('_legacy', '').to_sym
		end

		def specific_type client_url_name
			type = nil
			if client_url_name.match(/-/)
				cid = c[0..1]
				case cid
				when GOLFNOW_COM.to_s[0..1]
					type = :golf_now
				when GOLFADVISOR_COM.to_s[0..1]
					type = :golf_advisor
				when GOLFCOURSE_WEBSITE.to_s[0..1]
					type = :website_menu
				when GOLFFACEBOOK_TAB.to_s[0..1]
					type = :fb_tab
				end
			end
			if type.nil?
				type = legacy_type(client_url_name)
			end
			type
		end

		def legacy_type client_url_name
			if client_url_name.match(/_gnow/)
				:golf_now_legacy
			elsif client_url_name.match(/_menu_ga/)
				:golf_advisor_legacy
			elsif client_url_name.match(/_menu/)
				:website_menu_legacy
			elsif client_url_name.match(/_fb_tab/)
				:fb_tab_legacy
			else
				:unknown
			end
		end

	end
end








