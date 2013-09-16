module Mt
    module V1
        class MerchantToolsController < JsonController
            before_filter :authenticate_merchant_tools,    except: :create
            before_filter :authenticate_general_token,     only:   :create

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

    #####  Order Methods

            def orders
                data  = params["data"]
                if data["page"] == "new"
                    gifts = Gift.get_provider(@provider)
                elsif data["page"]  == 'reports'

                    start_time = data["start_time"].to_datetime if data["start_time"]
                    end_time   = data["end_time"].to_datetime   if data["end_time"]
                    puts "hitting the date correct #{start_time}|#{end_time}"
                    gifts = Gift.get_history_provider_and_range(@provider, start_time, end_time )
                else
                    puts "hitting get_history_provider"
                    gifts = Gift.get_history_provider(@provider)
                end

                if gifts
                    success array_these_gifts(gifts, MERCHANT_REPLY, false, true, true)
                else
                    fail    database_error
                end
                respond
            end

            def order
                if gift = Gift.find(params["data"].to_i)
                    serialized_gift = array_these_gifts( [gift], MERCHANT_REPLY, false , true , true )
                    success serialized_gift.first
                else
                    fail    data_not_found
                end
                respond
            end

    ######   Menu Methods

            def compile_menu
                data = params["data"]["old_menu"]           # deprecate
                menu = params["data"]["menu"]
                puts "Old Data = #{data}"                   # deprecate
                puts "new Data = #{menu}"
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

    #######   Reports Methods

            def summary_range
                if range = Gift.get_summary_range(@provider)
                    success(range)
                else
                    fail(data_not_found)
                end
                respond
            end

            def summary_report
                start_date = params["data"].to_datetime
                end_date   = range_end start_date
                if resp = Gift.get_summary_report(@provider, start_date.utc, end_date.utc)
                    success resp
                else
                    fail    data_not_found
                end
                respond
            end

        private

            def range_end date
                if date.day > 15
                    date.end_of_month
                else
                    (date.beginning_of_month + 14.days).end_of_day
                end
            end

        end
    end
end