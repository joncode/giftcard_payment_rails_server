class Web::V3::ClientsController < MetalCorsController
    include Email
	before_action :authenticate_general

	def index
		slug = params[:id]
		client = Client.where("active = 't' AND url_name = :q OR download_url = :q", q: slug).first
		if client # && client.active
			# success serialize
			client.click
			success client
		# elsif client && !client.active
		# 	# return deactivated client message
		# 	fail_web fail_web_payload("client_deactivated")
		else
			# client does not exist
			# client = match_client_to_url(slug)
			email_developers(client, slug)
			if client.kind_of?(Client) && client.active
				client.click
				success client
			else
				fail_web({ err: "INVALID_INPUT", msg: "Client could not be found"})
			end
		end
		respond
	end

	def create
		hsh = client_create_params

		ref = hsh[:ref]
		slug1 = hsh[:slug1]
		slug2 = hsh[:slug2]
		ary_of_slugs = [ ref, slug1, slug2 ]
		ary_of_slugs = ary_of_slugs.map { |a| remove_unwanted_url_parts(a) }

		if ary_of_slugs.length == 0
			# no data for client
			clients = ["No arrays of slugs", "no data"]
			fail_web({ err: "INVALID_INPUT", msg: "No Data"})
		else
			clients = Client.find_with_url ary_of_slugs

			client = nil
			if clients.length == 1
				client = clients[0]
			elsif clients.length == 0
				fail_web({ err: "INVALID_INPUT", msg: "Client could not be found"})
			else # clients.length > 1 menu widget and golf advisor widget
				val = nil
				ary_of_slugs.each do |sl|
					next if sl.nil?
					if sl.match(/_menu_ga/)
						# golf advisor slug
						val = sl
						break
					elsif sl.match(/_gnow/)
						# golf now slug
						val = sl
						break
					elsif sl.match(/_menu/)
						#standard menu widget
						val = sl
						break
					end
				end
				if val
					client = clients.where("url_name = '#{val}'").first
				elsif client = clients.where("download_url ilike '%#{ref}%'").first
					# menu widget
				else
					fail_web({ err: "INVALID_INPUT", msg: "Client could not be found"})
				end
			end
			if client
				client.click
				success client
			end
		end
		email_developers(clients, ary_of_slugs) unless client
		respond
	end

	def remove_unwanted_url_parts slug
		return nil if slug.blank?
			# if hyphen it is a region name must be ignored
			#  due to merchant URL's often contain region names
			# ie table34lasvegas.com contains lasvegas
		return nil if slug.match(/-/)
			# remove all unwanted characters
		ary_split = slug.to_s.split('.')
		if ary_split.length == 3
			domain = ary_split[1]
		elsif ary_split.length == 2
			domain = ary_split[0]
		else
			domain = slug.to_s
		end
		return nil if domain == 'itson'
		domain
	end

	def match_client_to_url url_id
		if url_id.match /itson.me/
			return Client.find(1) # itsonme client
		else
			ary_split = url_id.split('.')
			if ary_split.length == 3
				domain = ary_split[1]
			elsif ary_split.length == 2
				domain = ary_split[0]
			else
				domain = url_id
			end
			domain = domain.gsub('-','')
			ms = Merchant.where('website ilike ?', "%#{domain}%")
			if ms.length == 1
				merchant = ms.first
				client = Client.new(platform: :menu_widget, ecosystem: :partner,  data_type: :merchant)
				client.download_url = merchant.website
				client.partner_id = merchant.id
				client.partner_type = merchant.class.to_s
				client.url_name = (merchant.name.downcase + "_menu").gsub(' ', "_")
				client.name = merchant.name + " Web Menu Widget"
				client.detail = "Web client widget for #{merchant.name} website"
				if client.save
					client.content = merchant
					return client
				else
					puts "---------  Errors: #{client.errors.messages} #{url_id}  ---------"
					# error
					return client.errors.messages
				end
			elsif ms.length == 0
				unknown_client_id = Rails.env.staging? ? 12 : 8
				return Client.find(unknown_client_id)  # itsonme unknown url data client = 8
			else
				# multiple merchants
				return "Multiple Merchants #{ms.inspect}"
			end
		end
	end

	def html_email(client, slug)
		if client.nil?
			"<div><h2>Client #index has been requested for #{slug}.</h2>\
			<p>No client has been found . Client is nil</p></div>"
		else
			"<div><h2>Client #index has been requested for #{slug}.</h2>\
			<p>#{client.inspect}</p></div>"
		end
	end

	def email_developers(client, slug)
		email_data_hsh = {
			"subject" => "Web::V3::ClientsController - #{slug} requested a client",
			"html"    => html_email(client, slug).html_safe,
			"email"   => "devops@itson.me"
		}
		puts email_data_hsh.inspect
		notify_developers(email_data_hsh)
	end


	def client_create_params
		params.require(:data).permit(:ref, :slug1,  :slug2)
	end
end