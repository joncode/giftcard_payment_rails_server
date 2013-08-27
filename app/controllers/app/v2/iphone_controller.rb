module App
    module V2
        class IphoneController < JsonController

            before_filter :authenticate_services#,     except: [:create_account, :login]
            # before_filter :authenticate_general_token,  only: [:create_account, :login]

            def regift

                recipient_data = params["data"]["receiver"]
                if recipient_data["receiver_id"].to_i > 0
                    if not recipient = User.find recipient_data["receiver_id"]
                        puts "!!! APP SUBMITTED USER ID THAT DOESNT EXIST #{recipient_data} !!!"
                        recipient = make_user_with_hash(recipient_data)
                    end
                else
                    recipient = make_user_with_hash(recipient_data)
                end

                old_gift_id = params["data"]["regift_id"]
                message     = params["data"]["message"]

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

        private

            def make_user_with_hash(user_data_hash)
                recipient               = User.new
                recipient.first_name    = user_data_hash["name"]
                recipient.email         = user_data_hash["email"]
                recipient.phone         = user_data_hash["phone"]
                recipient.facebook_id   = user_data_hash["facebook_id"]
                recipient.twitter       = user_data_hash["twitter"]
                return recipient
            end

        end
    end
end