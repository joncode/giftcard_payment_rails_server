module LatLongSetter

    def self.update_lat_long
    	providers_lat = Provider.where(latitude: nil)
    	providers_long = Provider.where(longitude: nil)
    	puts "================  Providers with no lat #{providers_lat.count}"
    	puts "================  Providers with no long #{providers_long.count}"
    	providers_lat.each do |provider|
    		m = provider.merchant
    		provider.update(latitude: m.latitude, longitude: m.longitude )
    	end
    	providers_long.reload
    	if providers_long.count != 0
	    	providers_long.each do |provider|
	    		m = provider.merchant
	    		provider.update(latitude: m.latitude, longitude: m.longitude )
	    	end    		
    	end

    	providers_lat.reload
    	providers_long.reload
    	puts "================  Providers with no lat #{providers_lat.count}"
    	puts "================  Providers with no long #{providers_long.count}"



    end

end