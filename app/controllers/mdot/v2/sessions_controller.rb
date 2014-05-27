class Mdot::V2::SessionsController < JsonController
    before_action :authenticate_general_token

    rescue_from ActiveRecord::RecordInvalid, :with => :handle_rescue
    rescue_from JSON::ParserError, :with => :bad_request

    def create
        return nil if params_bad_request(["email", 'password', 'pn_token'])
        [params['email'], params['password']].each do |input|
            return nil if data_not_string?(input)
            return nil if data_blank?(input)
        end
        if user_social = UserSocial.includes(:user).where(type_of: 'email', identifier: params['email'].strip.downcase).references(:users).first
            @user = user_social.user
            if @user.not_suspended?
                if @user.authenticate(params['password'])
                    @user.pn_token = params['pn_token'] if params['pn_token']
                    success @user.create_serialize
                else
                    fail "Invalid email/password combination"
                    status = :not_found
                end
            else
                fail "We're sorry, this account has been suspended.  Please contact #{SUPPORT_EMAIL} for details"
                status = :unauthorized
            end
        else
            fail "Invalid email/password combination"
            status = :not_found
        end
        respond(status)
    end

    def login_social
        return nil if params_bad_request(["facebook_id", 'twitter', 'pn_token'])
        if params['facebook_id']
            # return nil if data_not_string?(params['facebook_id'])
            params['facebook_id'] = params['facebook_id'].to_s
            return nil if data_blank?(params['facebook_id'])
            user_social = UserSocial.includes(:user).where(type_of: 'facebook_id', identifier: params['facebook_id']).first
            @user = user_social ? user_social.user : nil
        elsif params['twitter']
            # return nil if data_not_string?(params['twitter'])
            params['twitter'] = params['twitter'].to_s
            return nil if data_blank?(params['twitter'])
            user_social = UserSocial.includes(:user).where(type_of: 'twitter', identifier: params['twitter']).first
            @user = user_social ? user_social.user : nil
        else
            head :bad_request
            return nil
        end
        if @user
            if @user.not_suspended?
                @user.pn_token = params['pn_token'] if params['pn_token']
                success @user.create_serialize
            else
                fail "We're sorry, this account has been suspended.  Please contact #{SUPPORT_EMAIL} for details"
                status = :unauthorized
            end
        else
            fail "Account not in #{SERVICE_NAME} database"
            status = :not_found
        end
        respond(status)
    end

private

    def handle_rescue
        success @user.create_serialize
        respond
        method_end_log_message
    end

end