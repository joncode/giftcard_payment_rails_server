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

            def coming_soon
                provider = Provider.find params['id']
                provider.sd_location_id = provider.live_bool ? nil : 1

                if provider.save
                    msg =
                        if provider.live_bool
                            "#{provider.name} is live"
                        else
                            "#{provider.name} is coming soon"
                        end
                    success msg
                else
                    fail provider
                end
                respond
            end

            def de_activate
                provider    = Provider.find params['id']
                new_active  = provider.active ? false : true
                if provider.update_attribute(:active, new_active)
                    success "#{provider.name} has changed to active = #{provider.active}"
                else
                    fail provider
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

        end
    end
end