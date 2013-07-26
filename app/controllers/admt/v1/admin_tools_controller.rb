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
                users = User.order("updated_at DESC")
                if users.count > 0
                    success users.serialize_objs :admt
                else
                    fail database_error
                end
                respond
            end

            def user
                if user = User.find(params["data"].to_i)
                    success user.serialize
                else
                    fail database_error
                end
                respond
            end

            def user_and_gifts
                # get the user with params["id"]
                # get the sent adn received gifts for the user
                if user = User.find(params["data"].to_i)
                    gifts        = Gift.get_sent_and_received_gifts_for user
                    gifts.each_key do |key|
                        gifts[key] = array_these_gifts( gifts[key], ADMIN_REPLY, false , false , true )
                    end
                    response_hsh = {app_user: user.admt_serialize}.merge gifts
                    success response_hsh
                else
                    fail user
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

            def brand
                if brand = Brand.find(params["data"].to_i)
                    success brand.serialize
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
                    fail admin_token_obj
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