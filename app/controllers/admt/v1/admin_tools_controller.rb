module Admt
    module V1
        class AdminToolsController < JsonController

            before_filter :authenticate_admin_tools,    except: :add_key
            before_filter :authenticate_general_token,  only:   :add_key

            def gifts
                gifts = Gift.order("updated_at DESC")
                if gifts.count > 0
                    success array_these_gifts( gifts, ADMIN_REPLY, false , false , true )
                else
                    fail database_error
                end
                respond
            end

            def users
                users = User.order("name ASC")
                if users.count > 0
                    success serialize_objs_in_ary users
                else
                    fail database_error
                end
                respond
            end

            def brands
                brands = Brand.order("updated_at DESC")
                if brands.count > 0
                    success serialize_objs_in_ary brands
                else
                    fail database_error
                end
                respond
            end

            def add_key
                admin_token = params["data"]
                # check to make sure the admin user already exists in db
                admin_token_obj = AdminToken.new(token: admin_token)
                if admin_token_obj.save
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
                api_key = AdminToken.find_by_token token
                head :unauthorized unless api_key
            end

            def authenticate_general_token
                token = params["token"]
                head :unauthorized unless GENERAL_TOKEN == token
            end

        end
    end
end