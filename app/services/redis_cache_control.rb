class RedisCacheControl

	# RedisCacheControl.rebuild_regions

	class << self


		def perform
				# rebuild the cities cache
			rebuild_regions  ##j- Probably not needed anymore.
			# rebuild_lists  ##j+
				# rebuild merchants in each city /  list
			rebuild_region_merchants  ##j- Probably not needed anymore.
				# rebuild each merchant cache
			rebuild_merchants
				# rebuild each menu cache
			rebuild_menus
			return 'RedisCacheControl.perform 200 OK'
		end

		def rebuild_menus
			Menu.all.each do |menu|
				begin
	            	menu_response = JSON.parse(menu.json)
	            	RedisWrap.set_menu(menu.id, menu_response) unless (menu_response.blank?)
	            rescue
	            	next
	            end
	        end
		end

		def rebuild_merchants
			Client.all.each do |client|
				next if !client.active || (client.clicks == 0)
	            arg_scope = proc { Merchant.where(active: true).where(paused: false).order("name ASC") }
	            merchants = client.contents(:merchants, &arg_scope)
	            merchants_serialized = merchants.serialize_objs(:web)
	            RedisWrap.set_merchants(client.id, merchants_serialized) unless (merchants_serialized == [])
	        end
		end


		def rebuild_regions
			Client.all.each do |client|
				next if !client.active || (client.clicks == 0)
	            arg_scope = proc { Region.index_with_inactives }
		        cities_serialized = client.contents(:regions, &arg_scope).map(&:city_with_active_json)
	            RedisWrap.set_cities(client.id, cities_serialized) unless (cities_serialized == [])
	        end
		end

		def rebuild_region_merchants
			Region.index.each do |region|
            	arg_scope = proc { region.merchants }
            	Client.all.each do |client|
            		next if !client.active || (client.clicks == 0)
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