require 'rest_client'

class WwwHttpService

	def self.clear_merchant_cache
		puts "\n clearing www merchant cache"
		begin
			resp = RestClient.get(
			    "#{PUBLIC_IOM}/shop/clearcache",
			    {:content_type => :html }
			)
		rescue => e
			resp = e
			puts "\n\nWWW Clear Cache Error = #{resp}\n\n"
		end
		puts "cache response is #{resp.inspect}"
	end

end