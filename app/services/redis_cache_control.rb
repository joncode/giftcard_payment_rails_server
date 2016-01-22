class RedisCacheControl

	class << self


		def perform
				# rebuild the cities cache
			self.rebuild_regions
				# rebuild merchants in each city /  list
			self.rebuild_region_merchants
				# rebuild each merchant cache
			self.rebuild_merchants
				# rebuild each menu cache
			self.rebuild_menu
		end

		def rebuild_menus
			Merchant.all.each do |merchant|
	            menu_responses = { "menu" =>  merchant.menu_string, "loc_id" => merchant.id }
	            RedisWrap.set_menu(merchant.menu_id, menu_responses)
	        end
		end

		def rebuild_merchants
			Clients.all.each do |client|
	            arg_scope = proc { Merchant.where(active: true).where(paused: false).order("name ASC") }
	            merchants = client.contents(:merchants, &arg_scope)
	            merchants_serialized = merchants.serialize_objs(:web)
	            RedisWrap.set_merchants(client.id, merchants_serialized)
	        end
		end


		def rebuild_regions
			Client.all.each do |client|
	            arg_scope = proc { Region.index }
		        cities_serialized = client.contents(:regions, &arg_scope).map(&:old_city_json)
	            RedisWrap.set_cities(client.id, cities_serialized)
	        end
		end

		def rebuild_region_merchants
			Region.index.each do |region|
            	arg_scope = proc { region.merchants }
            	Clients.all.each do |client|
	            	merchants = client.contents(:merchants, &arg_scope)
	            	if !merchants.nil? && merchants.count > 0
	                	if region.city?
	                    	merchants = merchants.select{ |m| m.city_id == region_id }
	                	end
	                	merchants_serialized = merchants.serialize_objs(:web)
		                RedisWrap.set_region_merchants(client.id, region_id, merchants_serialized)
		            end
		        end
			end
		end

	end

end