module Web
    module V1
        class WebsitesController < JsonController

            def confirm_email
                confirm_token = params[:id]
                if setting = Setting.where(confirm_email_token: confirm_token)

                    if user = User.find_by_email(params[:email])
                        if user.id == user_id
                            confirm   = "1" + user.confirm[1]
                            user.update_attribute(:confirm, confirm)

                        else

                        end
                    else

                    end

                else
                    fail data_not_found
                end

                respond
            end

            def redo_confirm_email
                email = params[:id]


                respond
            end

        end
    end
end