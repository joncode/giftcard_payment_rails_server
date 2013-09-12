module Web
    module V1
        class WebsitesController < JsonController

            def confirm_email
                confirm_token = params[:id]
                if setting = Setting.where(confirm_email_token: confirm_token)

                    if user = setting.user

                    else
                        fail database_error
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