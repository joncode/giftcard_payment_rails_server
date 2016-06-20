class FacebookCronJob


	def self.check_tokens
		os = Oauth.all
		facebook_oauth ||= Koala::Facebook::OAuth.new(FACEBOOK_APP_ID, FACEBOOK_APP_SECRET)
		os.each do |o|
			begin
				graph = Koala::Facebook::API.new(o.token, FACEBOOK_APP_SECRET)
			rescue
				puts "NO SECRET #{o.id}"
				graph = Koala::Facebook::API.new(o.token)
			end
			p = graph.get_object("me")
			puts p.inspect
			resp = facebook_oauth.exchange_access_token_info o.token
			puts resp.inspect
		end
	end


end