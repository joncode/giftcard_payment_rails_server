class RedisCacheControl

	class << self


		def perform
				# rebuild the cities cache
			rebuild_regions
				# rebuild merchants in each city /  list
			rebuild_region_merchants
				# rebuild each merchant cache
			rebuild_merchants
				# rebuild each menu cache
			rebuild_menus
			return 'RedisCacheControl.perform 200 OK'
		end

		def rebuild_menus
			Merchant.all.each do |merchant|
	            menu_responses = { "menu" =>  merchant.menu_string, "loc_id" => merchant.id }
	            RedisWrap.set_menu(merchant.menu_id, menu_responses) unless (menu_responses == [])
	        end
		end

		def rebuild_merchants
			Client.all.each do |client|
	            arg_scope = proc { Merchant.where(active: true).where(paused: false).order("name ASC") }
	            merchants = client.contents(:merchants, &arg_scope)
	            merchants_serialized = merchants.serialize_objs(:web)
	            RedisWrap.set_merchants(client.id, merchants_serialized) unless (merchants_serialized == [])
	        end
		end


		def rebuild_regions
			Client.all.each do |client|
	            arg_scope = proc { Region.index }
		        cities_serialized = client.contents(:regions, &arg_scope).map(&:old_city_json)
	            RedisWrap.set_cities(client.id, cities_serialized) unless (cities_serialized == [])
	        end
		end

		def rebuild_region_merchants
			Region.index.each do |region|
            	arg_scope = proc { region.merchants }
            	Client.all.each do |client|
	            	merchants = client.contents(:merchants, &arg_scope)
	            	if !merchants.nil? && merchants.count > 0
	                	if region.city?
	                    	merchants = merchants.select{ |m| m.city_id == region.id }
	                	end
	                	merchants_serialized = merchants.serialize_objs(:web)
		                RedisWrap.set_region_merchants(client.id, region.id, merchants_serialized) unless (merchants_serialized == [])
		            end
		        end
			end
		end

	end

end