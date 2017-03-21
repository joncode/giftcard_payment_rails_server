module ClientMaker
	# extend this module - Class methods



	def new_clover_client merchant
		# find other clients for partner
		return nil unless merchant.persisted?
		# cs = Client.where(platform: 7, partner_id: merchant.id, partner_type: merchant.class.to_s)
		client = Client.new(platform: :clover, ecosystem: :full, data_type: :merchant)
		client.partner_id = merchant.id
		client.partner_type = merchant.class.to_s
		client.url_name = clover_pos_redemtion_url_name(merchant, DateTime.now.utc.to_i)
		client.name = merchant.venue_name.to_s + ' Clover'
		client.detail = "CloverPOS redemption credentials for #{merchant.venue_name}"
		client.download_url = nil
		client.ecosystem = :partner
		client.data_id = merchant.id
		client.data_type = merchant.class.to_s.underscore.to_sym
		return client
	end

#   -------------

	def new_list_client list
		client = new(platform: :menu_widget, ecosystem: :standalone, data_type: :list)
		client.data_id = list.id
		client.url_name = list.token
		client.download_url = client.url_name_full_path
		client.name = list.name.to_s + " Client"
		client.detail = list.description
		if list.owner_id.nil?
			list.save   # applies default owner
		end
		client.partner_id = list.owner_id
		client.partner_type = list.owner_type

		return client
	end

#   -------------

	def new_redemption partner=nil
		client = new(platform: :redemption, ecosystem: :standalone, data_type: :unknown)
		unless partner.nil?
			client.partner_id = partner.id
			client.partner_type = partner.class.to_s
			client.url_name = partner.name + "-redemption"
			client.name = partner.name + " Redemption Client"
			client.detail = "#{partner.name} Multi Redemption Client"
			client.download_url = partner.website
		end
		return client
	end

	def create_redemption partner
		client = new_redemption(partner)
		if client.save
			cc = (client.content = partner)
			if cc.persisted?
				partner.update(client_id: client.id)
				client
			else
				"Client Created but unable to connect partner"
			end
		else
			client
		end
	end

#   -------------

	def init_all_clients partner, golf=false
		clients = []
		menu_client = new_web_menu(partner)
		clients << menu_client

		fb_client = new_facebook_menu(partner)
		clients << fb_client

		sp_client = new_singleplatform_menu(partner)
		clients << sp_client

		if golf
			ga_client = new_golf_advisor(partner)
			clients << ga_client
			gnow_client = new_golf_now(partner)
			clients << gnow_client
		end

		return clients
	end

	def create_all_clients partner, golf=false
		clients = init_all_clients(partner, golf)
		clients.each do |client|
			unless client.save
				puts client.errors
			end
		end
		return clients
	end

#   -------------

	def clover_pos_redemtion_url_name merchant, num
		"CLOVER-#{merchant.pos_merchant_id}-#{merchant.venue_name.parameterize}-V#{num}"
	end

	def web_menu_url_name partner
		"#{GOLFCOURSE_WEBSITE}-#{partner.id}-#{partner.name.parameterize}"
	end

	def facebook_url_name partner
		"#{GOLFFACEBOOK_TAB}-#{partner.id}-#{partner.name.parameterize}"
	end

	def golf_advisor_url_name partner
		"#{GOLFADVISOR_COM}-#{partner.id}-#{partner.name.parameterize}"
	end

	def golf_now_url_name partner
		"#{GOLFNOW_COM}-#{partner.id}-#{partner.name.parameterize}"
	end

	def singleplatform_url_name partner
		"#{SINGLEPLATFORM_ID}-#{partner.id}-#{partner.name.parameterize}"
	end

#   -------------

	def new_singleplatform_menu partner
		client = Client.new(platform: :menu_widget, ecosystem: :full, data_type: :merchant)
		client.partner_id = partner.id
		client.partner_type = partner.class.to_s
		client.url_name = singleplatform_url_name(partner)
		client.name = partner.name + " SinglePlatform Menu"
		client.detail = "SinglePlatform Menu for #{partner.name}"
		client.download_url = partner.website
		client.data_id = partner.id if partner.class == Merchant
		return client
	end

	def new_web_menu partner=nil
		client = new(platform: :menu_widget, ecosystem: :full, data_type: :merchant)
		unless partner.nil?
			client.partner_id = partner.id
			client.partner_type = partner.class.to_s
			client.url_name = web_menu_url_name(partner)
			client.name = partner.name + " Web Menu Widget"
			client.detail = "Menu widget for #{partner.name}"
			client.download_url = partner.website
			client.data_id = partner.id if partner.class == Merchant
		end
		return client
	end

	def new_facebook_menu partner
		client = Client.new(platform: :menu_facebook, ecosystem: :full, data_type: :merchant)
		client.partner_id = partner.id
		client.partner_type = partner.class.to_s
		client.url_name = facebook_url_name(partner)
		client.name = partner.name + " Facebook Tab Menu"
		client.detail = "Facebook Tab Menu for #{partner.name}"
		client.download_url = partner.facebook_url
		client.data_id = partner.id if partner.class == Merchant
		return client
	end

	def new_golf_advisor merchant
		gaclient = Client.new(platform: :menu_widget, ecosystem: :full, data_type: :merchant)
		gaclient.partner_id = merchant.id
		gaclient.partner_type = merchant.class.to_s
		gaclient.url_name = golf_advisor_url_name(merchant)
		gaclient.name = merchant.name + " Golf Advisor Widget"
		gaclient.detail = "Golf Advisor widget for #{merchant.name}"
		gaclient.download_url = merchant.golf_advisor_url || "http://www.golfadvisor.com/courses/#{merchant.slug}"
		gaclient.data_id = merchant.id
		return gaclient
	end

	def new_golf_now merchant
		gnowclient = Client.new(platform: :menu_widget, ecosystem: :full, data_type: :merchant)
		gnowclient.partner_id = merchant.id
		gnowclient.partner_type = merchant.class.to_s
		gnowclient.url_name = golf_now_url_name(merchant)
		gnowclient.name = merchant.name + " GolfNow Widget"
		gnowclient.detail = "GolfNow widget for #{merchant.name}"
		gnowclient.download_url = merchant.golf_now_url || "http://www.golfnow.com/tee-times/facility/#{merchant.slug}"
		gnowclient.data_id = merchant.id
		return gnowclient
	end

end