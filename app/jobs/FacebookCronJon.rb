class FacebookCronJob


	def check_tokens
		os = Oauth.all
		facebook_oauth ||= Koala::Facebook::OAuth.new(FACEBOOK_APP_ID, FACEBOOK_APP_SECRET)
		os.each do |o|
			graph = Koala::Facebook::API.new(o.token, FACEBOOK_APP_SECRET)
			p = graph.get_object("me")
			puts p.inspect
			resp = facebook_oauth.exchange_access_token_info o.token
			puts resp.inspect
		end
	end


end