module Web
    module V1
        class WebsitesController < JsonController
            before_filter :authenticate_www_token

            def confirm_email
                confirm_token = params[:confirm_token]
                if setting = Setting.where(confirm_email_token: confirm_token)
                    if  setting.confirm_email_token_sent_at > (Time.now - 10.days)
                        # update the setting to be confirmed
                        if setting.update_attribute(:confirm_email_flag, true)
                            # send success back
                            success "email confirmed"
                        else
                            fail({"msg" => "user update failed , please retry", "error" => "database"})
                        end
                    else
                        fail({"msg" => "confirm email expired", "error" => "invalid"})
                    end
                else
                    fail({"msg" => "confirm email not found", "error" => "invalid"})
                end

                respond
            end

            def redo_confirm_email
                email = params[:token]


                respond
            end

        end
    end
end