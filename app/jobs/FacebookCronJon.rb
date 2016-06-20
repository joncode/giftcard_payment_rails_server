class FacebookCronJob


	def self.check_tokens
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


end