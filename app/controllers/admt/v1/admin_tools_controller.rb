module Admt
    module V1
        class AdminToolsController < JsonController

            before_filter :authenticate_admin_tools,    except: :add_key
            before_filter :authenticate_general_token,  only:   :add_key

    #####  Gift Methods

            def gifts
                gifts = Gift.order("updated_at DESC")
                if gifts.count > 0
                    success array_these_gifts( gifts, ADMIN_REPLY, false , false , true )
                else
                    fail    database_error
                end
                respond
            end

            def gift
                gift = Gift.find(params["data"].to_i)
                if gift
                    serialized_gift = array_these_gifts( [gift], ADMIN_REPLY, false , false , true )
                    success serialized_gift.first
                else
                    fail    database_error
                end
                respond
            end

            def destroy_all_gifts
                user        = User.find(params["data"].to_i)
                total_gifts = Gift.get_user_activity(user)
                total_gifts.each {|gift| gift.destroy}

                if Gift.get_user_activity(user).count == 0
                    success "Gifts Destroyed."
                else
                    fail "Error in batch delete gifts"
                end
                respond
            end

    #####  Gift & Sale Methods

            def cancel_transaction
                gift = Gift.find(params["data"].to_i)
                if gift
                    success "Gift De-Activated"
                else
                    fail "Error De-Activating Unpaid gift"
                end
                respond
            end

            def refund_close
                gift = Gift.find(params["data"].to_i)
                if gift
                    success "Gift De-Activated and transaction refunded"
                else
                    fail "Error De-Activating and refunding Un-redeemed gift"
                end
                respond
            end

            def refund
                gift = Gift.find(params["data"].to_i)
                if gift
                    success "Gift De-Activated and transaction refunded"
                else
                    fail "Error De-Activating and refunding redeemed gift"
                end
                respond
            end

    #####  User Routes

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

            def de_activate_user
                user        = User.find(params["data"].to_i)
                user.active = user.active ? false : true

                if user.save
                    stat    = user.active ? "Active" : "De-Activated"
                    success "User is now #{stat}"
                else
                    fail user
                end
                respond
            end

            def destroy_user
                user        = User.find(params["data"].to_i)

                if user.destroy
                    success "#{user.name} is destroyed."
                else
                    fail user
                end
                respond
            end

    #####   Brand Routes

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

    #####  Merchant Routes

            def go_live
                provider = Provider.find_by_token params['data']
                provider.sd_location_id = provider.live_bool ? nil : 1

                if provider.save
                    msg =
                        if provider.live_bool
                            "#{provider.name} is Live in App"
                        else
                            "#{provider.name} is Coming Soon in App"
                        end
                    success msg
                else
                    fail provider
                end
                respond
            end

            def de_activate_merchant
                provider    = Provider.find_by_token params['data']
                new_active  = provider.active ? false : true

                if provider.update_attribute(:active, new_active)
                    msg =
                        if provider.active
                            "#{provider.name} is Active"
                        else
                            "#{provider.name} is de-Activated"
                        end
                    success msg
                else
                    fail provider
                end
                respond
            end

    ##### Utility Methods

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