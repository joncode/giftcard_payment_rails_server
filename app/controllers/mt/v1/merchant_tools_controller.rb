module Mt
    module V1
        class MerchantToolsController < JsonController
            before_filter :authenticate_merchant_tools,    except: :create
            before_filter :authenticate_general_token,     only:   :create

            def create
                puts "HERE IS THE PARAMS data = #{params["data"].inspect}"
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
                    end
                    puts "Here is merchant = #{merchant.inspect}"

                else
                    puts "Here is merchant = #{merchant.inspect}"
                    fail merchant
                end
                respond
            end

        end
    end
end