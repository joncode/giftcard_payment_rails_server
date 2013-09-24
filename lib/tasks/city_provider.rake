namespace :db do

  desc "Fill database with sample city_providers"
  task populate_city_provider: :environment do

    Provider.all.each do |p|
    	unless CityProvider.where(city: p.city).present?
    	    providers = Provider.where(city: p.city)
	    	  providers_array = providers.serialize_objs
       	  CityProvider.create(city: p.city,
      	  	 			            providers_array: providers_array)
    	end
    end
  end
end