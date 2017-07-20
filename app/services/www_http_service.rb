require 'rest_client'

#  WwwHttpService.clear_merchant_cache

class WwwHttpService

	def self.clear_merchant_cache
		puts "\n #{Rails.env} clearing web merchant cache"
		if Rails.env.production? || Rails.env.staging?
			begin
				resp = RestClient.get(
				    "#{CLEAR_CACHE}/system/clearcache",
				    {:content_type => :html }
				)
			rescue => e
				resp = e
				puts "\n\nWWW Clear Cache Error = #{resp}\n\n"
			end
			puts "cache response is #{resp.inspect}"
		end
	end

end