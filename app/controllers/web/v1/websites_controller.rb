module Web
    module V1
        class WebsitesController < JsonController

            def confirm_email
                confirm_token = params[:id]



                respond
            end

            def redo_confirm_email
                email = params[:id]


                respond
            end

        end
    end
end