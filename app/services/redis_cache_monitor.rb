# RedisCacheMonitor.perform

class RedisCacheMonitor
	extend Email

	class << self

		def perform
			log_level = Rails.logger.level
			Rails.logger.level = 1
			Diffy::Diff.default_format = :html
			redis = Resque.redis

				# find the redis keys used for API caches
			cache_keys = select_only_cache_keys redis
				# go thru each cache key

			bust_www_cache = false
			cache_keys.each do |key|

				puts "RedisCacheMonitor - checking #{key}"

					# get the current cache data in stringified JSON
				current_cache = redis.get(key)
				if current_cache.blank? || (current_cache == "[]")
					puts "RedisCacheMonitor:25 - #{key} Key Deleted"
					redis.del(key)
				end

				if redis.ttl(key) == -1
					puts "RedisCacheMonitor:29 - #{key} Expiration Added"
					redis.expire(key, 87000)
				end
					# generate fresh cache string in stringified JSON
				fresh_cache = fresh_cache_from_database(key)

					# compare the cache stringified JSON
				if fresh_cache.blank?
					puts "RedisCacheMonitor:33 - #{key} Value blank 404 - Not Found"
					next
				elsif (current_cache == fresh_cache)
					puts "RedisCacheMonitor:36 - #{key} 304 - Not Modified"
					next
				else
						# if not the same
						# set the cache to the correct value
					seconds_to_live = 1800 if key.match /user/
					RedisWrap.set_key(key, JSON.parse(fresh_cache), seconds_to_live)
						# diff the cache strings
					html_diff = Diffy::Diff.new(current_cache, fresh_cache).to_s
					html_diff = html_diff.gsub('<del>','<h3>Old Cache</h3><div>').gsub('<ins>','<h3>New Cache</h3><div>').gsub('</del>','</div>').gsub('</ins>','</div>')
					html_diff = "<h2>#{key}</h2>" + html_diff
						# send an email to tech with the 2 strings and the diff
					puts "500 Internal RedisCacheMonitor:47 | cache diff = #{html_diff} |"
					email_data_hsh = {
		                "subject" => "RedisCacheMonitor - CACHE ERROR FOUND #{key}",
		                "html"    => html_diffy,
		                "email"   => "jon.gutwillig@itson.me"
					}
					notify_developers(email_data_hsh)
					bust_www_cache = true if seconds_to_live.nil?
				end

			end
			WwwHttpService.clear_merchant_cache if bust_www_cache
			Rails.logger.level = log_level
		end

		def fresh_cache_from_database key
				# get the data from psql
			ary = key.split(':')
			obj1 = ary[0].singularize.capitalize.constantize.find ary[1]
			if obj1.kind_of?(Menu)
				obj1.json
			elsif obj1.kind_of?(User)
				user = obj1
				if ary[2] == 'profile'
					user.login_client_serialize.to_json
				else
					puts "500 Internal - RedisCacheMonitor:72 - unhandled item(2) #{ary[2]}"
					nil
				end
			elsif obj1.kind_of?(Client)
				client = obj1
				if ary[2].match /region/
					region = Region.find ary[3]
	            	arg_scope = proc { region.merchants }
	            	merchants = client.contents(:merchants, &arg_scope)
	            	if !merchants.nil? && merchants.count > 0
	                	if region.city?
	                    	merchants = merchants.select{ |m| m.city_id == region.id }
	                	end
	                	merchants.serialize_objs(:web).to_json
		            else
		            	nil
		            end
				elsif ary[2].match /cities/
		            arg_scope = proc { Region.index }
		            client.contents(:regions, &arg_scope).map(&:old_city_json).to_json
				elsif ary[2].match /user/
					user = User.find ary[3]
					if ary[4].match /gift/
			            gifts = Gift.get_user_activity_in_client(user, client)
			            gifts.serialize_objs(:web).to_json
					else
						puts "500 Internal - RedisCacheMonitor:98 - unhandled key #{key}"
						nil
					end
				elsif ary[2].match /merchant/
		            arg_scope = proc { Merchant.where(active: true).where(paused: false).order("name ASC") }
		            client.contents(:merchants, &arg_scope).serialize_objs(:web).to_json
		        end
			else
				puts "500 Internal - RedisCacheMonitor:106 - unhandled key #{key}"
				nil
			end
		rescue
			puts "500 Internal - failure key #{key}"
			nil
		end

		def select_only_cache_keys redis
				# get all the redis keys
			all_keys = redis.keys
			all_keys.select do |key|
				if key.match /user/
					true
				elsif key.match /merchant/
					true
				elsif key.match /region/
					true
				elsif key.match /client/
					true
				elsif key.match /menu/
					true
				else
					false
				end
			end
		end

	end


end