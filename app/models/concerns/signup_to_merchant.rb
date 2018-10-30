module SignupToMerchant
    extend ActiveSupport::Concern
    include AddressHelper
 # {"id"=>2,
 # 	"name"=>"JHon",
 # 	 "position"=>"",
 # 	 "email"=>"jon@jon.com",
 # 	 "phone"=>"7869882223",
 # 	 "website"=>"tes.com",
 # 	  "venue_name"=>"Test",
 # 	  "venue_url"=>"Test",
 # 	  "point_of_sale_system"=>"hello",
 # 	  "message"=>"",
 # 	  "created_at"=>Thu, 09 Apr 2015 23:20:23 UTC +00:00,
 # 	  "updated_at"=>Thu, 09 Apr 2015 23:20:23 UTC +00:00}


    def merchant_from_hash(args)
        m = Merchant.new

        # Shared settings
        m.address = args['address']
        m.name = args['venue_name']
        m.phone = args['phone']
        m.pos_sys = args['point_of_sale_system']
        m.website = args['venue_url']


        # Surfboard signup
        if args['data']['signup_source'] == 'Surfboard'
            m.address         = args['address']
            m.address_2       = args['data']['address_2']                rescue nil
            m.city_name       = args['data']['venue']['city']
            m.contract_date   = DateTime.now.utc
            m.description     = args['data']['description']
            m.email           = args['email']
            m.photo           = args['data']['photos']['cover']['path']  rescue nil
            m.photo_l         = args['data']['photos']['logo' ]['path']  rescue nil
            m.signup_email    = args['email']
            m.signup_name     = args['name']
            m.state           = set_state_to_abbreviation(args['data']['venue']['state'])
            m.tou             = args['data']['tos']
            m.zinger          = args['data']['zinger']
            m.zip             = args['data']['venue']['zip']
            m.yelp            = args['data']['venue']['yelp_url']        rescue nil
            m.building_id     = args['data']['venue']['golfnow_facility_id']  rescue nil

        # Clover signup
        elsif args['point_of_sale_system'] == 'clover' && args['position'] == 'CloverPOS'
            flash[:notice] = "Please move City State Zip out of address and into fields"

            m.pos_merchant_id = args['message']
            m.signup_email = args['name']


        # Anything else
        else
            m.signup_email = args['email']
            m.signup_name = args['name']
        end
        m
    end


end
