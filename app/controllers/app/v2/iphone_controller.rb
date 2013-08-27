module App
    module V2
        class IphoneController < JsonController

            before_filter :authenticate_services#,     except: [:create_account, :login]
            # before_filter :authenticate_general_token,  only: [:create_account, :login]

            def regift
                recipient   = User.new(params["data"]["receiver"])
                old_gift_id = params["data"]["regift_id"]
                message     = params["data"]["message"]
                # get the gift from the gift ID
                if old_gift = Gift.find(old_gift_id.to_i)
                    new_gift = old_gift.regift(recipient, message)
                    new_gift.save
                    old_gift.update_attribute(:status, 'regifted')
                    success(new_gift.serialize)
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