class FacebookOperations

	def self.get_graph gift
		giver = gift.giver
		oauth_obj = giver.current_oauth
        Koala::Facebook::API.new(oauth_obj.token, FACEBOOK_APP_SECRET)
	end

	def self.post_gift_to_wall gift_id
		gift = Gift.find gift_id
		gift_obscured_id = gift.obscured_id
		graph = self.get_graph(gift)
        post_id_hsh = graph.put_wall_post( "Here is  Gift for you:)", { :link => "#{PUBLIC_URL}/signup/acceptgift/#{gift_obscured_id}" }, gift.facebook_id)
		puts "POSTED TO FACEBOOK WALL post_gift_to_wall #{post_id_hsh}\n"
		return { 'success' => true, 'post' => post_id_hsh }
	end

	def self.notify_gift gift
        oauth = gift.oauth
        cart = JSON.parse gift.shoppingCart
        post_hsh = { "merchant"  => gift.provider_name,
        	"title" => cart[0]["item_name"],
        	"url" => "#{PUBLIC_URL}/signup/acceptgift?id=#{gift.obscured_id}" }
        # social_proxy = SocialProxy.new(oauth.to_proxy)
        # social_proxy.create_post(post_hsh)
        # puts "------ #{social_proxy.msg}"

        graph = self.get_graph(gift)
        post_id_hsh = graph.put_wall_post( "You've Received a Gift!", post_hsh, gift.facebook_id)
        puts "POSTED TO FACEBOOK WALL notify_gift #{post_id_hsh}\n"
        return { 'success' => true, 'post' => post_id_hsh }
	end

	def self.put_conn gift
        graph = self.get_graph(gift)
        post_id_hsh = graph.put_connections(g.facebook_id, subject: "Gifted!", message: g.message, link: "#{PUBLIC_URL}/signup/acceptgift/#{gift_obscured_id}" )
		puts "POSTED TO FACEBOOK WALL put_conn #{post_id_hsh}\n"
		return { 'success' => true, 'post' => post_id_hsh }
	end

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
				return { 'success' => false, 'error' => user.errors.full_messages}
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

## PRIVATE API

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