class Web::V3::RegionsController < MetalCorsController

    before_action :authentication_no_token

    def index
        # binding.pry
        arg_scope = proc { Region.city }
        success @current_client.contents(:regions, &arg_scope).map(&:old_city_json)
        respond
    end

    def merchants
        # binding.pry
        arg_scope = proc { Provider.all }
        merchants = @current_client.contents(:merchants, &arg_scope)
        if !merchants.nil? && merchants.count > 0
            providers = merchants.select{ |m| m.city_id == params[:id].to_i}
            if providers[0].class == Merchant
                providers = providers.map(&:provider)
            end
        else
            providers = []
        end

        # binding.pry
        success providers.serialize_objs(:web)
        respond
    end

end
