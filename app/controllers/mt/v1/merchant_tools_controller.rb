module Mt
    module V1
        class MerchantToolsController < JsonController
            before_filter :authenticate_merchant_tools,    except: :create
            before_filter :authenticate_general_token,     only:   :create

            def create
                merchant_hsh = params["data"]
                if merchant  = Provider.create(merchant_hsh)
                    success "#{merchant.name} created"
                else
                    fail merchant
                end
                respond
            end

        end
    end
end