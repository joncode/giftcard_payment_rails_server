module HttpModel
    extend ActiveSupport::Concern


        def get(token: token, route: route)
            return fail_hsh unless (token && route)
            server_request(token, route, nil, "get")
        end

        def post(token: token, route: route, params: nil)
            return fail_hsh unless (token && route)
            server_request(token, route, params, "post")
        end

        def put(token: token, route: route, params: nil)
            return fail_hsh unless (token && route)
            server_request(token, route, params, "put")
        end

private

        def server_request(token, route, params, action)
            puts "API route-#{route}- params=#{params} - token = #{token} - action = #{action}"
            time_start = Time.now
            message = generate_message(token, params)
                begin
                    party_response = HTTParty.send(action, route, message)
                    resp = server_response(party_response)
                rescue
                    resp = { "status" => 0, "data" => 'Cannot reach server' }
                end
            time_end = ((Time.now - time_start) * 1000).round(1)
            puts "END API -#{route}- (#{time_end}ms)"
            resp
        end

        def server_response party_response
            puts "#{party_response}"
            puts "HERE IS THE RESPONSE \n #{party_response.code} - #{party_response.parsed_response}"
            if party_response.code == 200
                { "status" => party_response.code, "data" => party_response.parsed_response}
            elsif party_response.code == 401
                { "status" => party_response.code, "msg" => "Unauthorized"}
            elsif party_response.code == 400
                { "status" => party_response.code, "msg" => 'Request failed. Data unrecognized by server. 400'}
            elsif party_response.code == 403
                { "status" => party_response.code, "msg" => 'Forbidden'}
            elsif party_response.code == 404
                { "status" => party_response.code, "msg" => 'Not Found. 404'}
            elsif party_response.code == 407
                { "status" => party_response.code, "msg" => "Proxy Authentication Required", "data" => -1001 }
            elsif party_response.code == 500
                { "status" => party_response.code, "msg" => 'Server Error'}
            else
                puts "TRANSMISSION FAILED - #{party_response.code}"
                { "status" => party_response.code, "data" => "Network Failure. please retry. #{party_response.code}"}
            end
        end

        def fail_hsh
            { "status" => 0, "data" => "internal error"}
        end

        def generate_message token, params=nil
            {:headers => {"authorization" => token, 'Accept' => 'application/json'}, :body => { "data" => params }}
        end



end


