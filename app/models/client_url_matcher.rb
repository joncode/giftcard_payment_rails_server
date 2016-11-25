class ClientUrlMatcher

# GOLFNOW_COM = 331
# GOLFADVISOR_COM = 13326
# GOLFCOURSE_WEBSITE = 74
# GOLFFACEBOOK_TAB = 62
# SINGLEPLATFORM_ID = 86

	class << self

		def get_client slug
			ary = slug.split('-')
			return nil if ary.length < 3

			if [SINGLEPLATFORM_ID, GOLFNOW_COM, GOLFADVISOR_COM, GOLFCOURSE_WEBSITE, GOLFFACEBOOK_TAB].include?(ary[0].to_i)
					# matched client to channel ID
				Client.where("url_name like '#{ary[0]}-#{ary[1]}-%'").first
			end
		end

		def gen_type client_url_name
			type = specific_type(client_url_name)
			type.to_s.gsub('_legacy', '').to_sym
		end

		def specific_type client_url_name
			type = nil
			if client_url_name.match(/-/)
				cid = client_url_name[0..1]
				case cid
				when GOLFNOW_COM.to_s[0..1]
					type = :golf_now
				when GOLFADVISOR_COM.to_s[0..1]
					type = :golf_advisor
				when GOLFCOURSE_WEBSITE.to_s[0..1]
					type = :website_menu
				when GOLFFACEBOOK_TAB.to_s[0..1]
					type = :fb_tab
				when SINGLEPLATFORM_ID.to_s[0..1]
					type = :single_platform
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








