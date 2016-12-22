class Web::V3::ClientsController < MetalCorsController
    include Email
	before_action :authenticate_general

	def index
		slug = params[:id]
		client = Client.where("active = 't' AND url_name = :q OR download_url = :q", q: slug).first
		if client # && client.active
			# success serialize
			client.click
			Resque.enqueue(DittoJob, 'clients#index', 200, params, client.id, client.class.to_s)
			success client
		else
			Resque.enqueue(DittoJob, 'clients#index', 422, params)
			fail_web({ err: "INVALID_INPUT", msg: "Client could not be found"})
		end
		respond
	end

	def create
		hsh = client_create_params

        if hsh[:slug2].blank? && !hsh[:slug1].blank?
            	# get the client with slug 1 as url_name
        	client = ClientUrlMatcher.get_client(hsh[:slug1].to_s)
        	if client.nil?
        		client = Client.find_by(active: true, url_name: hsh[:slug1].to_s)
        	end
        end

        if client.nil?

			ref = hsh[:ref]
			slug1 = hsh[:slug1]
			slug2 = hsh[:slug2]
			ary_of_slugs = [ ref, slug1, slug2 ]
			ary_of_slugs = ary_of_slugs.map { |a| remove_unwanted_url_parts(a) }
			ary_of_slugs.compact!

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

			end
		end
		if client
			client.click
			success client
			Resque.enqueue(DittoJob, 'clients#create', 200, hsh, client.id, client.class.to_s)
		else
			Resque.enqueue(DittoJob, 'clients#create', 422, hsh)
		end
		respond
	end

	def remove_unwanted_url_parts slug
		return nil if slug.blank?
			# if hyphen it is a region name must be ignored
			#  due to merchant URL's often contain region names
			# ie table34lasvegas.com contains lasvegas
		if slug.match(/-/) && !slug.match(/_-_/)
			# dont need this if slug2 is blank for all single url widgets
			# if Rails.env.staging?
			# # see if new golfnow URL
			# 	ary = slug.to_s.split('-')
			# 	s1 = ary[0]
			# 	s2 = ary[1]
			# 	return nil if s1.nil? || s2.nil?
			# 	if (s1.to_i > 0) && (s1.length == s1.to_i.to_s.length) && (s2.to_i > 0) && (s2.length == s2.to_i.to_s.length)
			# 		domain = slug
			# 	else
			return nil
			# 	end
			# end
		end
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
		return nil if domain.length < 6
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