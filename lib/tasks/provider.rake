namespace :db do

  desc "Fill database with sample providers"
  task populate_providers: :environment do

    10.times do |n|
      name     = random_name
      email    = "sample-#{Time.now.to_formatted_s(:number)}@example.com"
      address  = "#{rand(500)} Happy Street"
      city     = random_city
      state    = state(city)
      zip      = zip(city)
      full_address =  "#{address} #{city}, #{state} #{zip}"
      latitude = rand(99999)
      longitude = rand(99999)
      sales_tax = "5%"
      phone = random_phone
      photo = "http://res.cloudinary.com/drinkboard/image/upload/c_fill,h_150,w_200,a_exif/v1374873914/hyohbonfavstdu0ifbqs.jpg"
      live_int = 1
      token = SecureRandom.urlsafe_base64
      Provider.create!(name: name,
                   	   address: address,
                       city: city,
                       state: state,
                       zip: zip,
                       # full_address: full_address,
                       # latitude: latitude,
                       # longitude: longitude,
                       # live_int: live_int,
                       sales_tax: sales_tax,
                       phone: phone,
                       photo: photo,
                       token: token)
    end

  end

    def random_phone
        # VALID_PHONE_REGEX = /1?\s*\W?\s*([2-9][0-8][0-9])\s*\W?\s*([2-9][0-9]{2})\s*\W?\s*([0-9]{4})(\se?x?t?(\d*))?/
        phone = ""
    	10.times do
       	  phone + (2..8).to_a.sample.to_s
       	end
       	phone
    end

    def random_name
      first  = ["red", "orange", "yellow", "green", "blue", "purple", "silver", "white", "black", "happy", "mad", "sad", "ultra", "super", "extra", "extreme", "great"]
      second = ["banana", "apple", "kiwi", "grape", "melon", "potato", "lettuce", "carrot"]
      third  = ["cafe", "bar", "restaurant", "tavern", "foodstand", "house"]
      "#{first.sample} #{second.sample} #{third.sample}"
    end

    def random_city      
        ["Las Vegas", "New York", "Los Angeles", "City_No.#{rand(100)}"].sample
    end

    def state(city)
    	case city
    	when "Las Vegas"
    		"NV"
    	when "New York"
    		"NY"
    	when "Los Angeles"
    		"CA"
    	else
    		"NV"
    	end
    end

    def zip(city)
    	case city
    	when "Las Vegas"
    		"89109"
    	when "New York"
    		"10011"
    	when "Los Angeles"
    		"98012"
    	else
    		"89109"  
		end  	
    end

end