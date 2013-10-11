
class Admt::V1::AdminToolsController < JsonController

    before_filter :authenticate_admin_tools,    except: [:add_key, :payable_gifts]
    before_filter :authenticate_merchant_tools, only:   :payable_gifts
    before_filter :authenticate_general_token,  only:   :add_key

#####  Gift Methods

    def gifts
        data      = params["data"].to_i

        gifts = if data > 0
            Gift.get_all_for_provider data
        else
            Gift.get_all
        end

        if gifts.count > 0
            success array_these_gifts( gifts, ADMIN_REPLY, false , false , true )
        else
            fail    data_not_found
        end
        respond
    end

    def gift

        if gift = Gift.unscoped.find(params["data"].to_i)
            serialized_gift = array_these_gifts( [gift], ADMIN_REPLY, false , false , true )
            success serialized_gift.first
        else
            fail    data_not_found
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
            fail    "Error in batch delete gifts"
        end
        respond
    end

    def payable_gifts
        gift_ids = params["data"]
        if gifts = Gift.find(gift_ids)
            success gifts.serialize_objs(:report)
        else
            fail    data_not_found
        end
        respond
    end

    def payable_gifts_admt
        gift_ids = params["data"]
        if gifts = Gift.find(gift_ids)
            success gifts.serialize_objs(:report)
        else
            fail    data_not_found
        end
        respond
    end


#####  Gift & Sale Methods

    def cancel
        if gift = Gift.unscoped.find(params["data"].to_i)
            case gift.pay_stat
            when "charged"
                # void the gift - no sale
                gift.update_attribute(:pay_stat, "void")
                response = gift.pay_stat
            else
                sale     = gift.sale
                response = sale.fail_update_gifts gift
            end

            if gift
                success response
            else
                fail    "Error De-Activating gift"
            end
        else
            fail    data_not_found
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
            response_hsh   = {app_user: user.admt_serialize}.merge gifts
            success response_hsh
        else
            fail    data_not_found
        end
        respond
    end

    def users
        users = User.order("last_name ASC")

        if users.count > 0
            success users.serialize_objs :admt
        else
            fail    database_error
        end
        respond
    end

    def user
        if user = User.find(params["data"].to_i)
            success user.serialize
        else
            fail    data_not_found
        end
        respond
    end

    def update_user
        user = User.find(params["data"]["user_id"].to_i)
        if user && user.update_attributes(params["data"]["user"])
            success user.serialize
        else
            if user
                fail user
            else
                fail data_not_found
            end
        end
        respond
    end

    def deactivate_user
        if user         = User.find(params["data"].to_i)

            if user.toggle! :active
                stat    = user.active ? "Live" : "Suspended"
                success "#{user.name} is now #{stat}"
            else
                fail    user
            end
        else
            fail    data_not_found
        end
        respond
    end

    def destroy_user
        if user        = User.find(params["data"].to_i)

            if user.permanently_deactivate
                success "#{user.name} is Permanently De-Activated."
            else
                fail    user
            end
        else
            fail    data_not_found
        end
        respond
    end

#####   Brand Routes

    def brands
        brands = Brand.get_all
        if brands.count > 0
            success brands.serialize_objs(:admt)
        else
            fail    database_error
        end
        respond
    end

    def brand
        if brand = Brand.unscoped.find(params["data"].to_i)
            success brand.admt_serialize
        else
            fail    database_error
        end
        respond
    end

    def create_brand
        puts "HERE IS THE PARAMS data = #{params["data"].inspect}"
        brand_hsh = params["data"]
        brand     = Brand.new brand_hsh
        if brand.save
            puts    "Here is new brand ID = #{brand.id} = #{brand.inspect}"
            success brand.admt_serialize
        else
            fail    brand
        end
        respond
    end

    def update_brand
        brand = Brand.unscoped.find(params["data"]["brand_id"].to_i)
        if brand && brand.update_attributes(params["data"]["brand"])
            success brand.admt_serialize
        else
            if brand
                fail brand
            else
                fail data_not_found
            end
        end
        respond
    end

    def deactivate_brand
        if brand      = Brand.unscoped.find(params["data"].to_i)

            if brand.toggle! :active
                msg = if brand.active
                        "#{brand.name} is Active"
                    else
                        "#{brand.name} is de-Activated"
                    end
                success msg
            else
                fail    brand
            end
        else
            fail    data_not_found
        end
        respond
    end

    def associate
        type_of  = params["data"]["type_of"]
        type_msg = type_of == "building_id" ? "building" : "brand"
        begin
            brand    = Brand.unscoped.find(params["data"]["brand_id"].to_i)
            merchant = Provider.unscoped.find(params["data"]["provider_id"].to_i)
        rescue
            brand = nil
        end
        if brand && merchant && (type_of == "building_id" || type_of == "brand_id" )
            if merchant.send(type_of)  != brand.id
                merchant.send(type_of, brand.id)
                msg = "#{brand.name} is #{type_msg} associated with #{merchant.name}"
            else
                merchant.send(type_of, nil)
                msg = "#{brand.name} is no longer #{type_msg} associated with #{merchant.name}"
            end
            if merchant.save
                success msg
            else
                fail    merchant
            end
        else
            # could not find brand or merchant
            fail    data_not_found
        end

        respond
    end

    def deassociate
        provider_id = params["data"]["provider_id"].to_i
        brand_id    = params["data"]["brand_id"].to_i
        type_of     = params["data"]["type_of"]
        if merchant = Provider.unscoped.find(provider_id)
            merchant.send("#{type_of}=", nil)
            if merchant.save
                success "De-association successfull"
            else
                fail    merchant
            end
        else
            # could not find brand or merchant
            fail    data_not_found
        end

        respond
    end

#####  Merchant Routes

    def providers
        providers = Provider.get_all
        if providers.count > 0
            success providers.serialize_objs(:admt)
        else
            fail    database_error
        end
        respond
    end

    def go_live
        if provider = Provider.unscoped.find_by_token(params['data'])

            if provider.toggle! :live
                msg =
                    if provider.live
                        "#{provider.name} is Live in App"
                    else
                        "#{provider.name} is Coming Soon in App"
                    end
                success msg
            else
                fail    provider
            end
        else
                fail    data_not_found
        end

        respond
    end

    def update_mode
        if provider = Provider.unscoped.find_by_token(params['data']['merchant_token'])
            provider.mode = params['data']['mode']
            if provider.save
                # call :mt and update the mechant
                response = provider.update_mode
                if response['status'] > 0
                    success     "#{provider.name} is #{provider.mode}"
                else
                    # set cron job to fix out of sync data in MT
                    hsh         = {"msg" => "app is updated.  Merchant Tools was unable to update."}
                    total_resp  = hsh.merge(provider.admt_serialize)
                    success     total_resp
                end
            else
                    fail        provider
            end
        else
                    fail        data_not_found
        end

        respond
    end

    def deactivate_merchant
        if provider    = Provider.unscoped.find_by_token(params['data'])

            if provider.update_attribute(:active, false)
                # call :mt and deactivate the merchant
                response = provider.deactivate_merchant
                if response['status'] > 0
                    success     "#{provider.name} is de-Activated"
                else
                    # set cron job to fix out of sync data in MT
                    hsh         = {"msg" => "#{provider.name} is de-Activated.  Merchant Tools was unable to update."}
                    total_resp  = hsh.merge(provider.admt_serialize)
                    success     total_resp
                end
            else
                fail    provider
            end
        else
            fail    data_not_found
        end
        respond
    end

    def orders
        if provider = Provider.unscoped.find_by_token(params['data'])

            if gifts = Gift.get_history_provider(provider)
                success array_these_gifts(gifts, MERCHANT_REPLY, false, true, true)
            else
                fail    provider
            end
        else
            fail    data_not_found
        end
        respond
    end

#####   Payment Routes

    def unsettled
        # get all the unsettled gifts (non-merchant specific)
        end_date = params["data"]
        gifts    = Gift.get_unsettled(end_date)

        if gifts.count > 0
            success gifts.serialize_objs :admt
        else
            fail    "No unsettled gifts at for end date of #{end_date}"
        end
        respond
    end

    def settled
        gift_id_ary       = params["data"]

        # change those gifts to settled
        gifts             = Gift.find(gift_id_ary)
        fail_update_gifts = []
        try_two           = []

        gifts.each do |gift|
            if not gift.update_attribute(:pay_stat, "settled")
                fail_update_gifts << gift
            end
        end

        fail_update_gifts.each do |gift|
            if not gift.update_attribute(:pay_stat, "settled")
                puts "!!! TRY TWO FAILURE !!! GIFT ID = #{gift.id}"
                try_two << gift
            end
        end

        if try_two.count == 0
            success "Gifts Updated to Settled"
        else
            fail    try_two.serialize_objs(:admt)
        end
        respond
    end

#####   Utility Methods

    def add_key
        admin_token = params["data"]
        # check to make sure the admin user already exists in db
        admin_token_obj = AdminToken.new(token: admin_token)
        if admin_token_obj.save
            success "Admin User Created"
        else
            fail    admin_token_obj
        end
        respond
    end

end