class RedisWrap

	def self.get_merchants(client_id)
		redis = Resque.redis
		merchants_json = redis.get("client:#{client_id}:merchants")
		if merchants_json.nil?
			return false
		else
			begin
				puts 'REDISWRAP - reading from cache'
				JSON.parse(merchants_json)
			rescue
				puts "\nReading from cache fail - #{merchants_json}\n"
				false
			end
		end
	end

	def self.set_merchants(client_id, merchants_serialized)
		redis = Resque.redis
		puts "\n setting cache for client #{client_id}\n"
		redis.set("client:#{client_id}:merchants", merchants_serialized.to_json)
	end

end