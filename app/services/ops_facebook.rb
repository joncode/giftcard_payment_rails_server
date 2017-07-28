class OpsFacebook

#   -------------  Utilities

	def self.permissions
		 ['user_posts','public_profile', 'user_friends', 'email', 'user_birthday', 'publish_actions', 'user_location']
	end

	def self.parse_error err
		print "500 Internal (self.parse_error) " + err.class.to_s  + err.inspect

		error_message = if err.respond_to?(:fb_error_user_msg)
			err.fb_error_user_msg
		elsif err.respond_to?(:fb_error_message)
			err.fb_error_message
		elsif err.respond_to?(:response_body)
			err.response_body
		elsif err.respond_to?(:message)
			err.message
		elsif err.respond_to?(:fb_error_user_title)
			err.fb_error_user_title
		elsif err.kind_of?(Hash)
			(err['fb_error_user_msg'] || err['fb_error_message'] || err['response_body'] || err['message'])
		else
			err
		end
		puts error_message.inspect + " OpsFacebook.parse_error"
		if error_message.nil? || error_message.match(/access token/)
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

	def self.reset_token
		facebook_oauth ||= Koala::Facebook::OAuth.new(FACEBOOK_APP_ID, FACEBOOK_APP_SECRET)

		# Checks the saved expiry time against the current time
		if facebook_token_expired?

			# Get the new token
			new_token = facebook_oauth.exchange_access_token_info(token_secret)

			# Save the new token and its expiry over the old one
			self.token_secret = new_token['access_token']
			self.token_expiry = new_token['expires']
			save
		end
	end

#   -------------  Basic Graph Queries

	def self.profile user, facebook_id=nil
		graph = self.get_graph(nil, user)
		return graph if graph.kind_of?(Hash)
		begin
			query_str = facebook_id || 'me'
			profile = graph.get_object(query_str)
		rescue => e
			return { 'success' => false, 'error' => self.parse_error(e) }
		end
		return { 'success' => true, 'data' => profile }
	end

	def self.get_feed user, datetime=nil
		graph = self.get_graph(nil, user)
		return graph if graph.kind_of?(Hash)
		datetime = DateTime.now - 15.days if datetime.nil?
		begin
			fd = graph.graph_call("v2.5/me/feed?fields=name,message,application,link&include_hidden=true&since=#{datetime.to_i}&limit=1000")
			{ 'success' => true, 'data' => fd }
		rescue => e
			puts "500 Internal OpsFacebook.get_feed for user ID = #{user.id} #{e.inspect}"
			{ 'success' => false, 'data' => self.parse_error(e) }
		end
	end

	def self.friends user
		graph = self.get_graph(nil, user)
		return graph if graph.kind_of?(Hash)
		app_friends = self.app_friends user
		taggable_friends = self.taggable_friends user
		if app_friends['success'] && taggable_friends['success']
			app_friend_names = []
			app_friends['data'].each do |f|
				f['is_taggable'] = false
				f['photo'] = "http://graph.facebook.com/#{f['id']}/picture?type=square"
				app_friend_names << f['name']
			end
			app_removed_taggable_friends = []
			taggable_friends['data'].each do |f|
				unless app_friend_names.include?(f['name'])
					hsh = { 'name' => f['name'], 'is_taggable' => true, 'id' => f['id'] }
					hsh['photo'] = f['picture']['data']['url']
					app_removed_taggable_friends << hsh
				end
			end
			friends = app_friends['data'] + app_removed_taggable_friends
			return { 'success' => true, 'data' => friends }
		else
			return { 'success' => false, 'error' => 'Please reconnect your Facebook profile.' }
		end
	end

	def self.app_friends user
		graph = self.get_graph(nil, user)
		return graph if graph.kind_of?(Hash)
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
		return graph if graph.kind_of?(Hash)
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
		more_friends = friends.respond_to?(:next_page) ? friends.next_page : []
		friends = friends + more_friends
		if more_friends.count == FACEBOOK_OPS_PAGE_LIMIT
			self.more_taggable_friends(friends)
		end
		friends
	end

	def self.notify_receiver_from_giver(gift)
		wall_post_res = nil
    	if gift.facebook_id.present?
    		wall_post_res = self.wall_post(gift)
    	else
            oa = gift.oauth
            if oa.present? && oa.network == 'facebook'
                gift.update(facebook_id: oa.network_id)
                wall_post_res = self.wall_post(gift)
            else
            	return { 'success' => false, 'data' => "not a Facebook Gift" }
            end
        end
        if wall_post_res.present? && wall_post_res['success']
	        post_id = wall_post_res['data']['id']
	        share = Share.new
	        share.network_id = post_id
	        share.user_action = 'gift_notify'
	        share.count = 1
	        share.gift_id = gift.id
	        if share.save
	        	puts "Share is saved #{share.inspect}"
	        else
	        	puts "500 Internal SHARE NOT SAVED #{share.inspect} #{share.errors.inspect}"
	        end
	        return { 'success' => true, 'data' => share }
	    else
	    	if wall_post_res['error'].present?
	    		return wall_post_res
	    	else
		    	return { 'success' => false, 'data' => "not a Facebook Gift" }
		    end
	    end
	end

#   -------------  Wall Posting

	def self.wall_post gift
        graph = self.get_graph(gift)
        return graph if graph.kind_of?(Hash)
		begin
			post_id_hsh = graph.graph_call("v2.5/me/#{FB_NAMESPACE}:send", { tags: "#{gift.facebook_id}",
				gift: "#{gift.invite_link}",
				message: " @[#{gift.facebook_id}], #{gift.message}",
				privacy: { 'value' => 'EVERYONE'},
				'fb:explicitly_shared' => 'true'}, 'post')
			puts "POSTED TO FACEBOOK WALL graph_call #{post_id_hsh.inspect}\n"
		rescue => e
			return { 'success' => false, 'error' => self.parse_error(e) }
		end
		return { 'success' => true, 'data' => post_id_hsh }
	end

#   -------------  Login / Connect to Account

	def self.login oauth_access_token, facebook_profile, user_social=nil
		if user_social.nil?
			user_social = UserSocial.includes(:user).where(identifier: facebook_profile['id'], type_of: 'facebook_id').first
		end
		if user_social.present?
			if user = user_social.user

				if user.facebook_id.blank?
					user = add_facebook_info_to_user(facebook_profile, user)
					if user.save
						return self.make_oauth_args(oauth_access_token, facebook_profile, user, user_social)
					else
						return { 'success' => false, 'error' => user.errors.full_messages.join('. ')}
					end
				else
					return self.make_oauth_args(oauth_access_token, facebook_profile, user, user_social)
				end

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
			if user.save
				return self.make_oauth_args(oauth_access_token, facebook_profile, user)
			else
				return { 'success' => false, 'error' => user.errors.full_messages.join('. ')}
			end
		end
	end

	def self.attach_account oauth_access_token, facebook_profile, user
		puts "ATTACH FACEBOOK #{facebook_profile.inspect}"
		user_social = UserSocial.includes(:user).where(identifier: facebook_profile['id'], type_of: 'facebook_id').first

		puts user_social.inspect

		if user_social.present? && user_social.user_id != user.id
			return { 'success' => false, 'error' => 'Facebook Account is authorized on a different user account' }
		elsif user_social.present? && user_social.user_id == user.id
			return self.make_oauth_args(oauth_access_token, facebook_profile, user)
		else

			user = add_facebook_info_to_user(facebook_profile, user)

			if user.save
				return self.make_oauth_args(oauth_access_token, facebook_profile, user)
			else
				return { 'success' => false, 'error' => user.errors.full_messages.join('. ')}
			end

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
			user.first_name = facebook_profile['first_name'] || facebook_profile['name'].split(' ')[0]
			user.last_name = facebook_profile['last_name'] || facebook_profile['name'].split(' ')[1]
			temp_password = SecureRandom.urlsafe_base64
			user.password = temp_password
			user.password_confirmation = temp_password
		end
		return user
	end

	def self.make_oauth_args(oauth_access_token, facebook_profile, user, user_social=nil)
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
			if user_social.nil?
				user_social = user.user_socials.where(type_of: 'facebook_id',
					identifier: facebook_profile['id'],
					active: true).first
			end
			user_social.update(status: 'live', msg: nil) unless user_social.blank?
			return { 'success' => true, 'user' => user }
		else
			return { 'success' => false, 'error' => 'Unable to Save Oauth Token' }
		end

	end

end


	# def self.post_gift_to_wall gift_id, user=:giver
	# 	gift = Gift.find gift_id
	# 	gift_obscured_id = gift.hex_id
	# 	graph = self.get_graph(gift)

 #    	if user == :giver
 #        	post_id_hsh = graph.put_wall_post( "@[#{gift.facebook_id}], here is  Gift for you:) giver ", { :link => "#{PUBLIC_URL}/hi/#{gift_obscured_id}" })
	# 	else
	# 		post_id_hsh = graph.put_wall_post( "@[#{gift.facebook_id}], here is  Gift for you:) receiver", { :link => "#{PUBLIC_URL}/hi/#{gift_obscured_id}" }, gift.facebook_id)
	# 	end
	# 	puts "POSTED TO FACEBOOK WALL post_gift_to_wall #{post_id_hsh}\n"
	# 	return { 'success' => true, 'post' => post_id_hsh }
	# end

	# def self.notify_gift gift, user=:giver
 #        oauth = gift.oauth
 #        cart = JSON.parse gift.shoppingCart
 #        post_hsh = { "merchant"  => gift.provider_name,
 #        	"title" => cart[0]["item_name"],
 #        	"link" => "#{gift.invite_link}" }
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
	# 	gift_obscured_id = gift.hex_id
	# 	graph = self.get_graph(gift)
	# 	hsh = { gift: "#{PUBLIC_URL}/hi/#{gift_obscured_id}", message: "Lets do this @[jon.gifter] #{Time.now}", privacy: { 'value' => 'EVERYONE'}, 'fb:explicitly_shared' => 'true'}
 #        if user == :giver
	#         post_id_hsh = graph.put_connections('me', '/me/itsonme_test:send', hsh)
 #    	else
	#         post_id_hsh = graph.put_connections(gift.facebook_id, '/me/itsonme_test:send', hsh)
 #    	end
	# 	puts "POSTED TO FACEBOOK WALL full_try #{post_id_hsh}\n"
	# 	return { 'success' => true, 'post' => post_id_hsh }
	# end

	# def self.put_conn gift
	# 	gift_obscured_id = gift.hex_id
 #        graph = self.get_graph(gift)
 #        post_id_hsh = graph.put_connections('me', 'itsonme_test:send', subject: "Gifted!", message: "@[#{gift.facebook_id}] #{gift.message}", privacy: { 'value' => 'EVERYONE'}, link: "#{PUBLIC_URL}/hi/#{gift_obscured_id}" )
	# 	puts "POSTED TO FACEBOOK WALL put_conn #{post_id_hsh}\n"
	# 	return { 'success' => true, 'post' => post_id_hsh }
	# end