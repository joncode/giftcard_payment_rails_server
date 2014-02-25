class Mdot::V2::CitiesController < JsonController
    before_action :authenticate_customer

    def index
        @app_response = city_list
        success @app_response
        respond
    end

    def merchants
        identifier = params[:id]
        if identifier.to_i > 0
            identifier = city_name_from_id identifier.to_i
        end
        providers = Provider.where(city: identifier)
        @app_response = providers.serialize_objs
        success @app_response
        respond
    end

private

    def city_list
        [{"name"=>"Las Vegas", "state"=>"Nevada", "city_id"=>1, "photo"=>"d|v1378747548/las_vegas_xzqlvz.jpg"}, {"name"=>"San Francisco", "state"=>"California", "city_id"=>4, "photo"=>"d|v1378747548/san_francisco_hv2bsc.jpg"}, {"name"=>"San Diego", "state"=>"California", "city_id"=>3, "photo"=>"d|v1378747548/san_diego_oj3a5w.jpg"}, {"name"=>"New York", "state"=>"New York", "city_id"=>2, "photo"=>"d|v1393292178/new_york_iriwla"}, {"name"=>"Santa Barbara", "state"=>"California", "city_id"=>5, "photo"=>"d|v1393292171/santa_barbara_lqln3n"}]
    end

    def city_name_from_id id_int
        city_name = nil
        city_list.each do |city|
            if city["city_id"] == id_int
                city_name = city["name"]
                break
            end
        end
        return city_name
    end

end
