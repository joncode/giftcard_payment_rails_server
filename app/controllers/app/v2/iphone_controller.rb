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

            def menu
                if menu = MenuString.get_menu_v2_for_provider(params["data"].to_i)
                    success menu
                else
                    fail    database_error
                end
                respond
            end

        end
    end
end