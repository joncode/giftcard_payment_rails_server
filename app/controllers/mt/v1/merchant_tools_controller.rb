module Mt
    module V1
        class MerchantToolsController < JsonController
            before_filter :authenticate_merchant_tools,    except: :create
            before_filter :authenticate_general_token,     only:   :create

            def create
                merchant_hsh = params["data"]
                merchant = Provider.new merchant_hsh
                if merchant.save
                    puts "Here is merchant = #{merchant.inspect}"
                    success "#{merchant.name} created"
                else
                    puts "Here is merchant = #{merchant.inspect}"
                    fail merchant
                end
                respond
            end

        end
    end
end