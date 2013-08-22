module App
    module V2
        class IphoneController < JsonController

            #before_filter :authenticate_services,     except: [:create_account, :login]
            #before_filter :authenticate_general_token,  only: [:create_account, :login]

            def regifter
                # get the gift from the gift ID
                if old_gift = Gift.find params["data"].to_i
                # make a new gift with regifting code
                    new_gift = old_gift.regift
                # save the new gift
                    new_gift.save
                # change the status of the old gift
                    old_gift.update_attribute(:status, 'regifted')
                    success new_gift.serialize
                else
                    fail    data_not_found
                end

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