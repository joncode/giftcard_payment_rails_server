class RedisWrap

	def self.get_merchants(client_id)
		redis = Resque.redis
		merchants_json = redis.get("client:#{client_id}:merchants")
		if merchants_json.nil?
			return false
		else
			begin
				puts 'REDISWRAP - merchants - reading from cache'
				JSON.parse(merchants_json)
			rescue
				puts "\nReading from - merchants - cache fail - #{merchants_json}\n"
				false
			end
		end
	end

	def self.set_merchants(client_id, merchants_serialized)
		redis = Resque.redis
		puts "\n setting - merchants - cache for client #{client_id}\n"
		redis.set("client:#{client_id}:merchants", merchants_serialized.to_json)
	end

	def self.get_menu(menu_id)
		redis = Resque.redis
		menu_json = redis.get("menu:#{menu_id}")
		if menu_json.nil?
			return false
		else
			begin
				puts 'REDISWRAP - menus - reading from cache'
				JSON.parse(menu_json)
			rescue
				puts "\nReading from - menus - cache fail - #{menu_json}\n"
				false
			end
		end
	end

	def self.set_menu(menu_id, menu_serialized)
		redis = Resque.redis
		puts "\n setting - menus - cache for #{menu_id}\n"
		redis.set("menu:#{menu_id}", menu_serialized.to_json)
	end

	def self.get_cities(client_id)
		redis = Resque.redis
		cities_json = redis.get("client:#{client_id}:cities")
		if cities_json.nil?
			return false
		else
			begin
				puts 'REDISWRAP - cities - reading from cache'
				JSON.parse(cities_json)
			rescue
				puts "\nReading from - cities - cache fail - #{cities_json}\n"
				false
			end
		end
	end

	def self.set_cities(client_id, cities_serialized)
		redis = Resque.redis
		puts "\n setting - cities - cache for client #{client_id}\n"
		redis.set("client:#{client_id}:cities", cities_serialized.to_json)
	end

	def self.get_region_merchants(client_id, region_id)
		redis = Resque.redis
		merchants_json = redis.get("client:#{client_id}:regions:#{region_id}")
		if merchants_json.nil?
			return false
		else
			begin
				puts 'REDISWRAP - regions - reading from cache'
				JSON.parse(merchants_json)
			rescue
				puts "\nReading from - regions - cache fail - #{merchants_json}\n"
				false
			end
		end
	end

	def self.set_region_merchants(client_id, merchants_serialized, region_id)
		redis = Resque.redis
		puts "\n setting - regions - cache for client #{client_id} #{region_id}\n"
		redis.set("client:#{client_id}:regions:#{region_id}", merchants_serialized.to_json)
	end

	def self.clear_cache(region_id)
		redis = Resque.redis
		if region_id.to_i > 0
			regions = redis.keys("*regions:#{region_id}")
		else
			regions = []
		end
		merchants = redis.keys("*merchants")
		ary_of_keys = regions + merchants
		ary_of_keys.each{ |key| redis.del(key) }
	end

end



 # redis.keys('*regions*')
 # redis.keys('client*')
 # ary_of_keys.each { |key| redis.del(key) }