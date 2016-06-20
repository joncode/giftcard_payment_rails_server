class FacebookCronJob


	def self.check_tokens
		os = Oauth.all
		facebook_oauth ||= Koala::Facebook::OAuth.new(FACEBOOK_APP_ID, FACEBOOK_APP_SECRET)
		os.each do |o|
			good = true
			begin
				graph = Koala::Facebook::API.new(o.token, FACEBOOK_APP_SECRET)
				p = graph.get_object("me")
			rescue
				begin
					puts "NO SECRET #{o.id}"
					graph = Koala::Facebook::API.new(o.token)
					p = graph.get_object("me")
				rescue
					puts "TOKEN IS BROKEN #{o.id}"
					good = false
				end
			end
			puts p.inspect
			resp = facebook_oauth.exchange_access_token_info o.token if good
			puts resp.inspect
		end
	end


end