
class Admt::V1::AdminToolsController < JsonController

    before_filter :authenticate_admin_tools,    except: [:add_key, :payable_gifts]
    before_filter :authenticate_merchant_tools, only:   :payable_gifts
    # before_filter :authenticate_general_token,  only:   :add_key

#####  Gift Methods

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

#####   Brand Routes

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

#####  Merchant Routes

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

#####   Payment Routes


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

end