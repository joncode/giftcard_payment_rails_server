class FacebookCronJob

	@queue = :subscription

	def self.perform
		check_tokens
	end


	def self.check_oauth_tokens
		os = Oauth.all
		facebook_oauth ||= Koala::Facebook::OAuth.new(FACEBOOK_APP_ID, FACEBOOK_APP_SECRET)
		os.each do |o|
			good = true
			begin
				graph = Koala::Facebook::API.new(o.token, FACEBOOK_APP_SECRET)
				puts graph.get_object("me")
			rescue => e
				puts e.inspect
				begin
					puts "NO SECRET #{o.id}"
					graph = Koala::Facebook::API.new(o.token)
					puts graph.get_object("me")
				rescue => e
					puts e.inspect
					puts "TOKEN IS BROKEN #{o.id}"
					good = false
				end
			end
			begin
				puts facebook_oauth.exchange_access_token_info o.token if good
			rescue => e
				puts e.inspect
			end
		end
	end

	def self.check_tokens

		uss = UserSocial.where(type_of: 'facebook_id', status: 'live', active: true)

		generic_msg = "Please Re-authorize your Facebook account credentials"

		uss.find_each do |us|
			o = us.user.current_oauth(net_id: us.identifier)
			if !o.kind_of?(Oauth)
					# nil is returned , no token exists for user social, must re-auth
				us.set_reauth(msg: generic_msg)
			else
				begin
					graph = Koala::Facebook::API.new(o.token)
					profile = graph.get_object("me")
				rescue => e
					if e.fb_error_code == 100 || e.fb_error_code == 1
						puts "FacebookCronJob (44) puts error without app_secret " + e.inspect
						# invalid app secret
						begin
							graph = Koala::Facebook::API.new(o.token, FACEBOOK_APP_SECRET)
							profile = graph.get_object("me")
						rescue => e
							err = e
							puts "FacebookCronJob (50) not working token " + e.inspect
							# save not working info to the user social
							# mark token as deactivated with mesage
						end
					else
						puts "FacebookCronJob (55) error " + e.inspect
					end


					if e.fb_error_code == 100
						# invalid app secret
						us.set_reauth(msg: generic_msg)
					elsif e.fb_error_code == 1
						# The access token does not belong to application 1010660852318410
						us.set_reauth(msg: generic_msg)
					elsif e.fb_error_code == 190 && e.fb_error_subcode == 463
						#Error validating access token: Session has expired on Sunday, 14-Feb-16 15:08:25 PST.
						#The current time is Monday, 20-Jun-16 14:34:01 PDT.
						us.set_reauth(msg: e.fb_error_message)
					elsif e.fb_error_code == 190 && e.fb_error_subcode == 460
						#Error validating access token: Session does not match current stored session.
						#This may be because the user changed the password since the time the session was
						#created or Facebook has changed the session for security reasons.

						# Error validating access token: The session has been invalidated because the user has changed the password.
						us.set_reauth(msg: e.fb_error_message)
					else
						#Invalid OAuth access token.
						us.set_reauth(msg: generic_msg)
					end
				end
			end
		end
	end


end

