module App
    module V2
        class IphoneController < JsonController

            #before_filter :authenticate_services,     except: [:create_account, :login]
            #before_filter :authenticate_general_token,  only: [:create_account, :login]

            def regifter
                # get the gift from the gift ID
                # make a new gift with regifting code
                # save the new gift
                # change the status of the old gift

                respond
            end

        end
    end
end