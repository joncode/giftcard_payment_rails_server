class Mdot::V2::CitiesController < JsonController
    before_filter :authenticate_customer

    def index
        @app_response = [{"name"=>"Las Vegas", "state"=>"Nevada", "city_id"=>1, "photo"=>"d|v1378747548/las_vegas_xzqlvz.jpg"}, {"name"=>"San Francisco", "state"=>"California", "city_id"=>4, "photo"=>"d|v1378747548/san_francisco_hv2bsc.jpg"}, {"name"=>"San Diego", "state"=>"California", "city_id"=>3, "photo"=>"d|v1378747548/san_diego_oj3a5w.jpg"}, {"name"=>"New York", "state"=>"New York", "city_id"=>2, "photo"=>"d|v1378747548/new_york_vks0yh.jpg"}]
        success @app_response
        respond
    end

    def merchants
        providers = Provider.where(city: params[:id])
        @app_response = providers.serialize_objs
        success @app_response
        respond
    end

end