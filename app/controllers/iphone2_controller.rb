class Iphone2Controller < AppController

    before_filter :authenticate_admin_tools,    except: :create_account
    before_filter :authenticate_general_token,  only:   :create_account

    def create_account
        data     = params["data"]
        pn_token = params["pn_token"] || nil

        # first name
        # last name
        # email
        # phone
        # password
        # retype password
        # facebook_id
        # twitter
        # handle
        # photo URL
        # pn_token


        if data.nil?
            message = "Data not received correctly. "
        else
            new_user = create_user_object(data)
            puts "HERE IS NEW USER DATA #{new_user.inspect}"
            message = ""
        end

        if new_user.save
            new_user.pn_token = pn_token if pn_token
            user_to_app       = {"user_id" => new_user.id, "token" => new_user.remember_token}
            @app_response     = { "success" => user_to_app }
            # success "Admin User Created"
        else
            message         += " Unable to save to database"
            error_msg_string = stringify_error_messages new_user if new_user
            @app_response    = { "error_server" => error_msg_string }
            # fail admin_token_obj
        end
        respond
    end

    def create_account

        if data.nil?
            message = "Data not received correctly. "
        else
            new_user = create_user_object(data)
            puts "HERE IS NEW USER DATA #{new_user.inspect}"
            message = ""
        end

        respond_to do |format|
            if !data.nil? && new_user.save
                new_user.pn_token = pn_token if pn_token
                user_to_app = {"user_id" => new_user.id, "token" => new_user.remember_token}
                response = { "success" => user_to_app }
            else
                message += " Unable to save to database"
                error_msg_string = stringify_error_messages new_user if new_user
                response = { "error_server" => error_msg_string }
            end
            @app_response = "iPhoneC #{response} && #{response.to_json}"
            format.json { render json: response }
        end
    end


private

    def authenticate_app
            # check token to see if it is good
        api_key = User.find_by_remember_token params["token"]
        head :unauthorized unless api_key
    end

    def authenticate_general_token
        token = params["token"]
        head :unauthorized unless APP_GENERAL_TOKEN == token
    end

    def create_user_object(data)
        if data.kind_of? String
            obj = JSON.parse data
        else
            obj = data
        end
        User.new(obj)
    end


end
