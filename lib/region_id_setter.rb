module RegionIdSetter

	def self.print_provider_counts providers
    	cities_array = { "Las Vegas" => 1, "New York" => 2, "San Diego" => 3, "San Francisco" => 4, "Santa Barbara" => 5 , "Philadelphia" => 6 }
	    cities_array.each do |c_name, c_id|
	    	puts "------------------------------------------------------------------------------------------------------------"
		    puts "-------------- #{c_name.capitalize} City Providers: #{providers.where(city: [c_name, c_name.downcase]).count}"
	    end
	    cities_array.each do |c_name, c_id|
	    	puts "------------------------------------------------------------------------------------------------------------"
		    puts "-------------- #{c_name.capitalize} Region Providers: #{providers.where(region_id: c_id).count}"
	    end
	end

    def self.update_region_id providers
    	print_provider_counts providers

    	regionless_provider_ids = []
    	providers.each do |provider|
	        case provider.city.downcase.strip
	        when "las vegas"
	            provider.update(region_id: 1)
	        when "new york"
	            provider.update(region_id: 2)
	        when "san diego"
	            provider.update(region_id: 3)
	        when "san francisco"
	            provider.update(region_id: 4)
	        when "santa barbara"
	            provider.update(region_id: 5)
	        when "philadelphia"
	        	provider.update(region_id: 6)
	        else
	        	regionless_provider_ids << provider.id
	        end
	    end

	    print_provider_counts providers
	    regionless_provider_ids
    end

end