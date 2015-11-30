class FacebookOps

	FACEBOOK_OPS_PAGE_LIMIT = 1000

#   -------------  Utilities

	def self.parse_error err
		puts err.response_body
		error_message = err.fb_error_user_msg || err.fb_error_message || err.response_body
		if error_message.match(/access token/)
			return "Looks like we have a problem with facebook authorization, please re-connect to facebook. (If you continue to see this message, upgrade your app)"
		end
		error_message
	end

	def self.get_graph gift=nil, user=nil
		if gift
			user = gift.giver
		end
		oauth_obj = user.current_oauth
		if oauth_obj.kind_of?(Oauth)
	        Koala::Facebook::API.new(oauth_obj.token, FACEBOOK_APP_SECRET)
	    else
	    	return { 'success' => false, 'error' => "Facebook profile token expired. Please re-authenticate Facebook. (If you continue to see this message, upgrade your app)" }
	    end
	end

#   -------------  Basic Graph Queries

	def self.profile user, facebook_id=nil
		graph = self.get_graph(nil, user)
		return graph if graph.kind_of?(Hash) && !graph['success']
		begin
			query_str = facebook_id || 'me'
			profile = graph.get_object(query_str)
		rescue => e
			return { 'success' => false, 'error' => self.parse_error(e) }
		end
		return { 'success' => true, 'data' => profile }
	end

	def self.friends user
		graph = self.get_graph(nil, user)
		return graph if graph.kind_of?(Hash) && !graph['success']
		app_friends = self.app_friends user
		taggable_friends = self.taggable_friends user
		if app_friends['success'] && taggable_friends['success']
			app_friends['data'].each do |f|
				f['is_taggable'] = false
				f['photo'] = "http://graph.facebook.com/#{f['id']}/picture?type=square"
			end
			taggable_friends['data'].each do |f|
				f['is_taggable'] = true
				f['photo'] = f['picture']['data']['url']
			end
			friends = app_friends['data'] + taggable_friends['data']
			return { 'success' => true, 'data' => friends }
		else
			return { 'success' => false, 'error' => 'Error on facebook friends' }
		end
	end

	def self.app_friends user
		graph = self.get_graph(nil, user)
		return graph if graph.kind_of?(Hash) && !graph['success']
		begin
			friends = graph.get_connections('me','friends')
		rescue => e
			return { 'success' => false, 'error' => self.parse_error(e) }
		end
		if friends.count == FACEBOOK_OPS_PAGE_LIMIT
			# call the pagination link
		end
		return { 'success' => true, 'data' => friends }
	end

	def self.taggable_friends user
		graph = self.get_graph(nil, user)
		return graph if graph.kind_of?(Hash) && !graph['success']
		begin
			friends = graph.graph_call("v2.5/me/taggable_friends", { limit: FACEBOOK_OPS_PAGE_LIMIT })
		rescue => e
			return { 'success' => false, 'error' => self.parse_error(e) }
		end
		if friends.count == FACEBOOK_OPS_PAGE_LIMIT
			friends = self.more_taggable_friends(friends)
		end
		return { 'success' => true, 'data' => friends }
	end

	def self.more_taggable_friends(friends)
		more_friends = friends.next_page
		friends = friends + more_friends
		if more_friends.count == FACEBOOK_OPS_PAGE_LIMIT
			self.more_taggable_friends(friends)
		end
		friends
	end

	def self.notify_receiver_from_giver(gift)
    	if gift.facebook_id.present?
    		self.graph_call(gift)
    	else
            oa = gift.oauth
            if oa.present? && oa.network == 'facebook'
                gift.update(facebook_id: oa.network_id)
                self.graph_call(gift)
            end
        end
	end

#   -------------  Wall Posting

	def self.graph_call gift
        graph = self.get_graph(gift)
        if Rails.env.production?
        	search_query = 'itsonme'
        else
        	search_query = 'itsonme_test'
        end
		post_id_hsh = graph.graph_call("v2.5/me/#{search_query}:send", { tags: "#{gift.facebook_id}",
			gift: "#{PUBLIC_URL}/signup/acceptgift/#{gift.obscured_id}",
			message: " @[#{gift.facebook_id}], #{gift.message}",
			privacy: { 'value' => 'EVERYONE'},
			'fb:explicitly_shared' => 'true'}, 'post')
		puts "POSTED TO FACEBOOK WALL graph_call #{post_id_hsh}\n"
		return { 'success' => true, 'post' => post_id_hsh }
	end

#   -------------  Login / Connect to Account

	def self.login oauth_access_token, facebook_profile, user_social=nil
		if user_social.nil?
			user_social = UserSocial.includes(:user).where(identifier: facebook_profile['id'], type_of: 'facebook_id').first
		end
		if user_social.present?
			if user = user_social.user
				add_facebook_info_to_user(facebook_profile, user)
				return self.make_oauth_args(oauth_access_token, facebook_profile, user)
			else
				return { 'success' => false, 'error' => 'User not Found' }
			end
		else
			return { 'success' => false, 'error' => 'User not Found' }
		end
	end

	def self.create_account oauth_access_token, facebook_profile, client, partner
		user_social = UserSocial.includes(:user).where(identifier: facebook_profile['id'], type_of: 'facebook_id').first
		if user_social.present?
			self.login oauth_access_token, facebook_profile, user_social
		else
			user = User.new(origin: 'fb')
			user.partner = partner
			user.client = client
			user = add_facebook_info_to_user(facebook_profile, user)
			if user.persisted?
				return self.make_oauth_args(oauth_access_token, facebook_profile, user)
			else
				return { 'success' => false, 'error' => user.errors.full_messages.join('. ')}
			end
		end
	end

	def self.attach_account oauth_access_token, facebook_profile, user
		user_social = UserSocial.includes(:user).where(identifier: facebook_profile['id'], type_of: 'facebook_id').first
		if user_social.present? && user_social.user.id == user.id
			add_facebook_info_to_user(facebook_profile, user)
			return self.make_oauth_args(oauth_access_token, facebook_profile, user)
		elsif user_social.present? && user_social.user.id != user.id
			return { 'success' => false, 'error' => 'Facebook Account is authorized on a different user account' }
		else
			add_facebook_info_to_user(facebook_profile, user)
			return self.make_oauth_args(oauth_access_token, facebook_profile, user)
		end
	end

#   -------------  PRIVATE API

	def self.add_facebook_info_to_user(facebook_profile, user)
		# {"id"=>"503107738",
		#  "birthday"=>"06/12/1981",
		#  "email"=>"ppobbs@hotmail.com",
		#  "first_name"=>"Brandon",
		#  "gender"=>"male",
		#  "last_name"=>"Peterson",
		#  "link"=>"http://www.facebook.com/503107738",
		#  "locale"=>"en_US",
		#  "name"=>"Brandon Peterson",
		#  "timezone"=>-7, "updated_time"=>"2015-08-06T08:41:18+0000",
		#  "verified"=>true}
		user.facebook_id = facebook_profile['id']
		if user.email.nil? && facebook_profile['email'].present?
			user.email = facebook_profile['email']
		end
		if user.birthday.nil? && facebook_profile['birthday'].present?
			user.birthday = facebook_profile['birthday']
		end
		if user.sex.nil? && facebook_profile['gender'].present?
			user.sex = facebook_profile['gender']
		end
		if user.iphone_photo.nil?
			user.iphone_photo = "http://graph.facebook.com/#{facebook_profile['id']}/picture"
		end
		if !user.persisted?
			user.first_name = facebook_profile['first_name']
			user.last_name = facebook_profile['last_name']
			temp_password = SecureRandom.urlsafe_base64
			user.password = temp_password
			user.password_confirmation = temp_password
		end
		if user.save
			user
		else
			puts user.errors.full_messages.inspect
			user
		end
	end

	def self.make_oauth_args(oauth_access_token, facebook_profile, user)
		#  id         :integer         not null, primary key
		#  gift_id    :integer
		#  token      :string(255)
		#  secret     :string(255)
		#  network    :string(255)
		#  network_id :string(255)
		#  handle     :string(255)
		#  photo      :string(255)
		#  created_at :datetime
		#  updated_at :datetime
		#  user_id    :integer
		puts "make_oauth_args"
		puts "#{oauth_access_token} - #{facebook_profile} - #{user}"
		if user.id.nil?
			user.reload
		end
		oauth_args =  { user_id: user.id, network: 'facebook', network_id: facebook_profile['id'], \
			token: oauth_access_token, photo: "http://graph.facebook.com/#{facebook_profile['id']}/picture"}

		if Oauth.create(oauth_args).persisted?
			return { 'success' => true, 'user' => user }
		else
			return { 'success' => false, 'error' => 'Unable to Save Oauth Token' }
		end

	end

end


	# def self.post_gift_to_wall gift_id, user=:giver
	# 	gift = Gift.find gift_id
	# 	gift_obscured_id = gift.obscured_id
	# 	graph = self.get_graph(gift)

 #    	if user == :giver
 #        	post_id_hsh = graph.put_wall_post( "@[#{gift.facebook_id}], here is  Gift for you:) giver ", { :link => "#{PUBLIC_URL}/signup/acceptgift/#{gift_obscured_id}" })
	# 	else
	# 		post_id_hsh = graph.put_wall_post( "@[#{gift.facebook_id}], here is  Gift for you:) receiver", { :link => "#{PUBLIC_URL}/signup/acceptgift/#{gift_obscured_id}" }, gift.facebook_id)
	# 	end
	# 	puts "POSTED TO FACEBOOK WALL post_gift_to_wall #{post_id_hsh}\n"
	# 	return { 'success' => true, 'post' => post_id_hsh }
	# end

	# def self.notify_gift gift, user=:giver
 #        oauth = gift.oauth
 #        cart = JSON.parse gift.shoppingCart
 #        post_hsh = { "merchant"  => gift.provider_name,
 #        	"title" => cart[0]["item_name"],
 #        	"link" => "#{PUBLIC_URL}/signup/acceptgift?id=#{gift.obscured_id}" }
 #        # social_proxy = SocialProxy.new(oauth.to_proxy)
 #        # social_proxy.create_post(post_hsh)
 #        # puts "------ #{social_proxy.msg}"

 #        graph = self.get_graph(gift)
 #        if user == :giver
 #        	post_id_hsh = graph.put_wall_post( "@[#{gift.facebook_id}], You've Received a Gift! giver", post_hsh)
 #        else
 #        	post_id_hsh = graph.put_wall_post( "@[#{gift.facebook_id}], You've Received a Gift! receiver", post_hsh, gift.facebook_id)
 #        end
 #        puts "POSTED TO FACEBOOK WALL notify_gift #{post_id_hsh}\n"
 #        return { 'success' => true, 'post' => post_id_hsh }
	# end

	# def self.full_try gift, user=:giver
	# 	gift_obscured_id = gift.obscured_id
	# 	graph = self.get_graph(gift)
	# 	hsh = { gift: "#{PUBLIC_URL}/signup/acceptgift/#{gift_obscured_id}", message: "Lets do this @[jon.gifter] #{Time.now}", privacy: { 'value' => 'EVERYONE'}, 'fb:explicitly_shared' => 'true'}
 #        if user == :giver
	#         post_id_hsh = graph.put_connections('me', '/me/itsonme_test:send', hsh)
 #    	else
	#         post_id_hsh = graph.put_connections(gift.facebook_id, '/me/itsonme_test:send', hsh)
 #    	end
	# 	puts "POSTED TO FACEBOOK WALL full_try #{post_id_hsh}\n"
	# 	return { 'success' => true, 'post' => post_id_hsh }
	# end

	# def self.put_conn gift
	# 	gift_obscured_id = gift.obscured_id
 #        graph = self.get_graph(gift)
 #        post_id_hsh = graph.put_connections('me', 'itsonme_test:send', subject: "Gifted!", message: "@[#{gift.facebook_id}] #{gift.message}", privacy: { 'value' => 'EVERYONE'}, link: "#{PUBLIC_URL}/signup/acceptgift/#{gift_obscured_id}" )
	# 	puts "POSTED TO FACEBOOK WALL put_conn #{post_id_hsh}\n"
	# 	return { 'success' => true, 'post' => post_id_hsh }
	# end