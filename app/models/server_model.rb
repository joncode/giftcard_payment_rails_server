module ServerModel

    GENERAL_ROUTES = []
    ADMIN_ROUTES   = []

###### Admint Tools

###### Merchant Tools

    def update_mode
        short_route = 'update_mode'
        request_server_with_route_and_params short_route , self.mode
    end

private

    def request_server_with_route_and_params short_route, data
        route , params = generate_route_and_params(short_route, data)
        begin
            puts "Here are the route #{route} adn the params #{params}"
            party_response = HTTParty.post(route, params)
            puts "HERE IS PARTY #{party_response.inspect}"
            server_response(party_response)
        rescue
            { "status" => 0, "data" => 'Cannot reach server'}
        end
    end

    def server_response party_response
        if party_response.code    == 200
            party_response.parsed_response
        elsif party_response.code == 401
            puts "TRANSMISSION Unauthorized - #{party_response.inspect}"
            { "status" => 0, "data" => 'Network Authorization Failed.[DBA]'}
        else
            # transmission failure
            puts "TRANSMISSION FAILED - #{party_response.inspect}"
            { "status" => 0, "data" => 'Network Failure. please retry.[DBA]'}
        end
    end

    def generate_route_and_params(short_route, data)
        route  = if ADMIN_ROUTES.include? short_route
            generate_admt_route(short_route)
        else
            generate_mt_route(short_route)
        end
        params = unless GENERAL_ROUTES.include? short_route
            generate_params(data)
        else
            generate_general_params(data)
        end
        return route, params
    end

    def generate_admt_route short_route
        admt_tools_api_version     = "v1/"
        ADMIN_URL + "/mt/" + admt_tools_api_version + short_route
    end

    def generate_mt_route short_route
        merchant_tools_api_version = "v1/"
        MERCHANT_URL + "/dba/" + merchant_tools_api_version + short_route
    end

    def generate_params data
        auth_params    = { "token" => self.token, "data" => data }
        { :body => auth_params }
    end

    def generate_general_params data
            # send json string to the merchant tools API
        auth_params    = { "token" => GENERAL_TOKEN, "data" => data }
        { :body => auth_params }
    end

end