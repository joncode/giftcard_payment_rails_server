class Mdot::V2::SessionsController < JsonController
    before_filter :authenticate_general_token

    rescue_from ActiveRecord::RecordInvalid, :with => :handle_rescue

    def create
        [params['email'], params['password']].each do |input|
            return nil if data_not_string?(input)
            return nil if data_blank?(input)
        end
        if user_social = UserSocial.includes(:user).where(type_of: 'email', identifier: params['email']).first
            @user = user_social.user
            if @user.not_suspended?
                if @user.authenticate(params['password'])
                    @user.pn_token = params['pn_token'] if params['pn_token']
                    success @user.serialize(true)
                else
                    fail "Invalid email/password combination"
                end
            else
                fail "We're sorry, this account has been suspended.  Please contact support@drinkboard.com for details"
            end
        else
            fail "Invalid email/password combination"
        end
        respond
    end

    def login_social
        if params['facebook_id']
            return nil if data_not_string?(params['facebook_id'])
            return nil if data_blank?(params['facebook_id'])
            user_social = UserSocial.includes(:user).where(type_of: 'facebook_id', identifier: params['facebook_id']).first
            @user = user_social ? user_social.user : nil
        elsif params['twitter']
            return nil if data_not_string?(params['twitter'])
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
                success @user.serialize(true)
            else
                fail "We're sorry, this account has been suspended.  Please contact support@drinkboard.com for details"
            end
        else
            fail "Account not in Drinkboard database"
        end
        respond
    end

private
    
    def handle_rescue
        success @user.serialize(true)
        respond
        method_end_log_message
    end

end