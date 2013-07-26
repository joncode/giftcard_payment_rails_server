module Admt
    module V1
        class AdminToolsController < JsonController

            before_action :authenticate_admin_tools,    except: :add_key
            before_action :authenticate_general_token,  only:   :add_key

            def gifts

                if true
                    success "#{merchant.name} is under review"
                else
                    fail merchant.errors.messages
                end
                respond
            end

            def add_key
                admin_token = params["data"]
                # check to make sure the admin user already exists in db
                if admin_token_obj = AdminToken.create(token: admin_token)
                    success "Admin User Created"
                else
                    fail admin_token_obj.errors.full_messages
                end
                respond
            end

        private

            def authenticate_admin_tools
                token   = params["token"]
                # check token to see if it is good
                api_key = AdminToken.find_by(token: token)
                head :unauthorized unless api_key
            end

            def authenticate_general_token
                token = params["token"]
                head :unauthorized unless GENERAL_TOKEN == token
            end

        end
    end
end