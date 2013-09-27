class Web::V1::WebsitesController < JsonController
    before_filter :authenticate_www_token

    def confirm_email
        confirm_token = params[:confirm_token]
        if setting = Setting.where(confirm_email_token: confirm_token).first
            if  setting.confirm_email_token_sent_at > (Time.now - 10.days)
                # update the setting to be confirmed
                if setting.update_attribute(:confirm_email_flag, true)
                    # send success back
                    success "email confirmed"
                else
                    fail({"msg" => "user update failed , please retry", "error" => "database"})
                end
            else
                fail({"msg" => "confirm email expired", "error" => "expired"})
            end
        else
            fail({"msg" => "confirm email not found", "error" => "invalid"})
        end

        respond
    end

    def redo_confirm_email
        email = params[:email]
        if user = User.find_by_email(email)
            user.init_confirm_email
            success email
        else
            fail({"msg" => "we do not have that email account on file", "error" => email})
        end
        respond
    end

end


# backend API call for confirm email system
# Confirm Email
# route is authenticated with a token = "nj3tOdJOaZa-qFx0FhCLRQ"
# you have received the confirm_email_token from the user as the /confirmemail/<confirm_email_token>
# send a POST to drinkboard server
# route = <db_server_url>/web/v1/confirm_email
# parameters are { "token" : "nj3tOdJOaZa-qFx0FhCLRQ", "confirm_token" : <confirm_email_token> }
# there are 4 possible responses
# 1 - success response
# => { "status" : 1, "data" : "email confirmed"}
#  you will know this by "status" : 1
# www should render a "you are confirmed landing page"
# 2 - failure - database could not update user and failed
# => { "status" : 0, "data" : {"msg" : "user update failed , please retry", "error" : "database"}}
#  you will know this by "status" : 0 && "error" : "database"
# www could either re-submit the request or tell user the server is unavailable retry later
# 3 - failure - confirm email has expired
# => { "status" : 0, "data" : {"msg" : "confirm email expired", "error" : "expired"}}
#  you will know this by "status" : 0 && "error" : :"expired"
#  www should alert the user that the link has expired , render an email input field , the user can submit an email and request (redo) confirm email
# 4 - failure - confirm email not found
# => {"msg" => "confirm email not found", "error" => "invalid"}}
#  you will know this by "status" : 0 && "error" : :"expired"
#  www should alert the user that the link was not found , render an email input field , the user can submit an email and request (redo) confirm email

# Request (redo) confirm email
# route is authenticated with a token = "nj3tOdJOaZa-qFx0FhCLRQ"
# you have received the email via the form
# send a POST to drinkboard server
# route = <db_server_url>/web/v1/redo_confirm_email
# parameters are { "token" : "nj3tOdJOaZa-qFx0FhCLRQ", "email" : <email> }
# there are 2 possible responses
# 1 - success response
# => { "status" : 1, "data" : <email>}
# www should render a landing page "An email to confirm account <email> has been sent to your inbox."
# 2 - failure response
# => { "status" : 0, "data" : {"msg" => "we do not have that email account on file", "error" => email}}
# www should render a page stating that we do not have that email account on file
#     page should have a link on it to contact support , send them a message









