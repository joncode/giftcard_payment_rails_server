class FacebookOperations

	def self.login oauth_access_token, facebook_profile, user_social=nil
		if user_social.nil?
			user_social = UserSocial.includes(:user).where(identifier: facebook_profile['id'], type_of: 'facebook_id').first
		end
		if user_social.present?
			if user = user_social.user
				add_facebook_info_to_user(facebook_profile, user)
				return make_oauth_args(oauth_access_token, facebook_profile, user, true)
			else
				return { 'success' => false, 'error' => 'User not Found' }
			end
		else
			return { 'success' => false, 'error' => 'User not Found' }
		end
	end

	def self.create_account oauth_access_token, facebook_profile
		user_social = UserSocial.includes(:user).where(identifier: facebook_profile['id'], type_of: 'facebook_id').first
		if user_social.present?
			self.login oauth_access_token, facebook_profile, user_social
		else
			user = User.new
			add_facebook_info_to_user(facebook_profile, user)
			return make_oauth_args(oauth_access_token, facebook_profile, user, true)
		end
	end

	def self.attach_account oauth_access_token, facebook_profile, user
		user_social = UserSocial.includes(:user).where(identifier: facebook_profile['id'], type_of: 'facebook_id').first
		if user_social.present? && user_social.user.id == user.id
			add_facebook_info_to_user(facebook_profile, user)
			return make_oauth_args(oauth_access_token, facebook_profile, user, false)
		elsif user_social.present? && user_social.user.id != user.id
			return { 'success' => false, 'error' => 'Facebook Account is authorized on a different user account' }
		else
			add_facebook_info_to_user(facebook_profile, user)
			return make_oauth_args(oauth_access_token, facebook_profile, user, false)
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
		user.save
	end

	def self.make_oauth_args(oauth_access_token, facebook_profile, user, session_token_obj=false)
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
		if user.id.nil?
			user.reload
		end
		oauth_args =  { user_id: user.id, network: 'facebook', network_id: facebook_profile['id'], \
			token: oauth_access_token, photo: "http://graph.facebook.com/#{facebook_profile['id']}/picture"}

		if Oauth.create(oauth_args).persisted?
			if session_token_obj
				user.session_token_obj =  SessionToken.create_token_obj(user, 'fb', nil, @current_client, @current_partner)
			end
			return { 'success' => true, 'user' => user }
		else
			return { 'success' => false, 'error' => 'Unable to Save Oauth Token' }
		end

	end


end