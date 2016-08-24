#######################

####  DO NOT UPDATE THIS FILE OUTSIDE OF drinkboard !!!   ####

####  Update in drinkboard and copy to MT & ADMT   ####

#######################

class RedisWrap

	class << self


########  Clear Caches

		def clear_merchants_caches(region_id)
			clear_all_keys("*region:#{region_id}")
			clear_all_keys("*merchants")
		end

		def clear_menu_cache(menu_id)
			clear_key("menu:#{menu_id}")
		end

		def clear_client_cache(client_id)
			clear_all_keys("clients:#{client_id}*")
		end

		def clear_region_cache(region_id)
			clear_all_keys("*region:#{region_id}")
			clear_all_keys("*cities")
		end

		def clear_all_user_gifts(user_id)
			clear_all_keys("*user:#{user_id}:gifts")
		end

		def clear_user_gifts(client_id, user_id)
			clear_all_keys("*user:#{user_id}:gifts")
		end

		def clear_badge(client_id, user_id)
			clear_all_keys("user:#{user_id}:badge")
		end

		def clear_profile(user_id)
			clear_all_keys("user:#{user_id}:profile")
		end

########  Getters / Setters

		def get_region_merchants(client_id, region_id)
			get_key("client:#{client_id}:region:#{region_id}")
		end

		def set_region_merchants(client_id, region_id, _serialized)
			set_key("client:#{client_id}:region:#{region_id}", _serialized)
		end

		def get_merchants(client_id)
			get_key("client:#{client_id}:merchants")
		end

		def set_merchants(client_id, _serialized)
			set_key("client:#{client_id}:merchants", _serialized)
		end

		def get_cities(client_id)
			get_key("client:#{client_id}:cities")
		end

		def set_cities(client_id, _serialized)
			set_key("client:#{client_id}:cities", _serialized)
		end

		def get_menu(menu_id)
			get_key("menu:#{menu_id}")
		end

		def set_menu(menu_id, _serialized)
			set_key("menu:#{menu_id}", _serialized)
		end

		def get_profile(user_id)
			get_key("user:#{user_id}:profile")
		end

		def set_profile(user_id, _serialized)
			set_key("user:#{user_id}:profile", _serialized, 1800)
		end

		def get_user_gifts(client_id, user_id)
			# get_key("client:#{client_id}:user:#{user_id}:gifts")
			nil
		end

		def set_user_gifts(client_id, user_id, _serialized)
			# set_key("client:#{client_id}:user:#{user_id}:gifts", _serialized, 1800)
			nil
		end

		def get_badge(client_id, user_id)
			get_key("client:#{client_id}:user:#{user_id}:badge")
		end

		def set_badge(client_id, user_id, _serialized)
			set_key("client:#{client_id}:user:#{user_id}:badge", _serialized, 1800)
		end

        def get_user_keys
            Resque.redis.keys.select { |k| k.match /user/ }.sort
        end

        def get_region_keys
        	Resque.redis.keys.select { |k| k.match /region/ }.sort
        end

        def get_menu_keys
        	Resque.redis.keys.select { |k| k.match /menu/ }.sort
        end

#############   Utility Methods

		def get_key(key)
			redis = Resque.redis
			value_json_str = redis.get(key)
			if value_json_str.nil?
				false
			else
				puts "REDISWRAP - get_key - #{key} reading from cache"
				JSON.parse(value_json_str)
			end
		rescue
			puts "\nREDISWRAP get_key - #{key} - 500 Internal cache FAIL - #{value_json_str}\n"
			false
		end

		def set_key(key, value_hsh, seconds_to_live=87000)
			if value_hsh.blank?
				return nil
			end
			redis = Resque.redis
			puts "\n REDISWRAP set_with_key - #{key} \n"
			redis.set(key, value_hsh.to_json)
			seconds_to_live ? redis.expire(key, seconds_to_live) : nil
		end

		def clear_key(redis_key)
			puts "\nREDISWRAP clear - #{redis_key} \n"
			redis = Resque.redis
			redis.del(redis_key)
		end

		def clear_all_keys(key_range_str)
			redis = Resque.redis
			ary = redis.keys(key_range_str)
			if ary.kind_of?(Array) && ary.length > 0
				res = ary.map { |k| redis.del(k) }
			else
				# no matches
			end
			puts "\nREDISWRAP clear all keys - #{key_range_str} #{res} \n"
		end

	end

end



 # redis.keys('*regions*')
 # redis.keys('client*')
 # ary_of_keys.each { |key| redis.del(key) }