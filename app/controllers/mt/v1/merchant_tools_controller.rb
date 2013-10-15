class Mt::V1::MerchantToolsController < JsonController
    before_filter :authenticate_merchant_tools,    except: [:create, :reconcile_merchants]
    before_filter :authenticate_general_token,     only:   [:create, :reconcile_merchants]

#####  Merchant Methods

    def create
        # puts "HERE IS THE PARAMS data = #{params["data"].inspect}"
        has_menu     = params["data"]["menu"].present?
        merchant_hsh = params["data"]["merchant"]
        if has_menu
            menu_hsh = params["data"]["menu"]
        end
        merchant = Provider.new merchant_hsh
        if merchant.save
            if has_menu
                menu_string         = merchant.menu_string
                menu_string.data    = menu_hsh[0]
                menu_string.menu    = menu_hsh[1]
                menu_string.version = 3
                if menu_string.save
                    # merchant saved with menu
                    success({ "provider" => merchant.id , "menu_string" => menu_string.id })
                else
                    # merchant saved but menu failed
                    success({ "provider" => merchant.id , "menu_string" => menu_string.errors.messages })
                end
            else
                success({ "provider" => merchant.id , "menu_string" => { "Menu" => "No menu uploaded" } })
            end

        else
            puts "Here is merchant = #{merchant.inspect}"
            fail merchant
        end
        respond
    end

    def update
        merchant_hash = params["data"]
        merchant_hash.delete("tz")
        if @provider.update_attributes(merchant_hash)
            success   "Merchant Update Successful"
        else
            fail      @provider
        end

        respond
    end

    def update_photo
        photo_url = params["data"]

        if @provider.update_attribute(:image, photo_url)
            success   "Photo Live on App"
        else
            fail      @provider
        end

        respond
    end

######   Menu Methods

    def compile_menu
        data = params["data"]["old_menu"]           # deprecate
        menu = params["data"]["menu"]
        # puts "Old Data = #{data}"                   # deprecate
        # puts "new Data = #{menu}"
        menu_string = @provider.menu_string
        if !menu_string                             # deprecate
            menu_string = MenuString.create(provider_id: @provider.id, data: "[]")
        end
        if menu_string.update_attributes({data: data, menu: menu, version: 3})
            success     "Menu Live on App"
        else
            fail        menu_string
        end
        respond
    end

    def reconcile_merchants
        db_attributes        = ["live", "paused"]
        provider_hash_for_mt = {}
        merchant_matches     = 0

        #For each merchant sent from mt to db...
        merchants = params["data"]
        merchants.each do |merchant|

        #find the provider in db with the same token...
            if Provider.unscoped.find_by_token(merchant["token"])
                merchant_matches += 1
                provider = Provider.unscoped.find_by_token(merchant["token"])
        #and for each of its attributes (except for "id")...
                provider_attributes = provider.attributes
                provider_attributes.delete("id")
                provider_attributes.delete("created_at")
                provider_attributes.delete("updated_at")
                provider_attributes.each do |attr_name, attr_value|
            #if the mt and db data doesn't match, then...
                    if attr_value.to_s != merchant[attr_name].to_s
                # if it's present in db but not mt, log a message...
                        if merchant[attr_name].blank?
                            puts "The value of #{attr_name} for merchant #{merchant["merchant_id"]} is present in db, but not in mt. No changes were made."
                #if it's a "db_attribute", add  the key/value pair to the data to be sent back to mt...
                        elsif db_attributes.include?(attr_name)
                            if provider_hash_for_mt.has_key? merchant["merchant_id"]
                                provider_hash_for_mt[merchant["merchant_id"]].merge!(attr_name => attr_value)
                            else
                                provider_hash_for_mt[merchant["merchant_id"]] = { attr_name => attr_value }
                            end
                        else
                # otherwise, overwrite the db value with the mt value.
                            provider.send("#{attr_name}=", merchant[attr_name])
                            if provider.save
                                overwrite_message = "DB UPDATE: The value of #{attr_name} for merchant #{merchant["merchant_id"]} was overwritten from #{attr_value} to #{merchant[attr_name]} in the app!"
                                puts overwrite_message
                                if provider_hash_for_mt.has_key? merchant["merchant_id"]
                                    provider_hash_for_mt[merchant["merchant_id"]].merge!(attr_name => overwrite_message)
                                else
                                    provider_hash_for_mt[merchant["merchant_id"]] = { attr_name => overwrite_message }
                                end
                            end
                        end
                    end
                end
            else
                provider_hash_for_mt[merchant["merchant_id"]] = "no corresponding provider"
            end
        end
        if merchant_matches > 0
            puts "#{merchant_matches} of the #{merchants.count} merchants in mt have a corresponding provider in db"
            success provider_hash_for_mt
        else
            fail "no merchant-provider matches"
        end
        respond
    end
    

end
