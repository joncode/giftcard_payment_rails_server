class Web::V3::FacebookController < MetalCorsController
    include ERB::Util

    # before_action :authentication_no_token
    # before_action :get_current_user_fb_oauth, except: :oauth
    before_action :authentication_token_required, except: [:oauth_init, :callback_url]
    rescue_from JSON::ParserError, :with => :bad_request


    def friends
        # sproxy = SocialProxy.new(@user_oauth.to_proxy)
        # sproxy.friends

        # if sproxy.status == 200
        #     if sproxy.data.count > 0
        #         BulkContact.upload(data: sproxy.data, user_id: @current_user.id)
        #     end
        #     success sproxy.data
        #     respond(status)
        # else
        #     fail    sproxy.data.to_s
        #     @app_response["msg"] = sproxy.msg
        #     status = sproxy.status
        #     respond(status)
        # end

    end

    def profile
        # sproxy = SocialProxy.new(@user_oauth.to_proxy)
        # sproxy.profile

        # if sproxy.status == 200
        #     success sproxy.data
        #     respond(status)
        # else
        #     fail    sproxy.data.to_s
        #     @app_response["msg"] = sproxy.msg
        #     status = sproxy.status
        #     respond(status)
        # end
    end

    def create
        # sproxy = SocialProxy.new(@user_oauth.to_proxy)
        # sproxy.create_post params["data"]

        # if sproxy.status == 200
        #     success sproxy.data
        #     respond(status)
        # else
        #     fail    sproxy.data.to_s
        #     @app_response["msg"] = sproxy.msg
        #     status = sproxy.status
        #     respond(status)
        # end
    end

    def oauth_init
        oauth = Koala::Facebook::OAuth.new(FACEBOOK_APP_ID, FACEBOOK_APP_SECRET, ecnew(params))
        redirect_url = oauth.url_for_oauth_code(scope: ['public_profile', 'user_friends', 'email'])
        # success redirect_url
        # respond(:found)
        redirect_to redirect_url
    end

    def callback_url
        oauth = Koala::Facebook::OAuth.new(FACEBOOK_APP_ID, FACEBOOK_APP_SECRET, callback_url_generator(params['token']))
        oauth_access_token = oauth.get_access_token(params['code'])
        graph = Koala::Facebook::API.new(oauth_access_token)
        profile = graph.get_object("me")
        return_params = dcnew(params['token'])
        puts profile.inspect
        puts return_params.inspect
        if profile['id'].present?
            case params['operation']
            when 'login'
                resp = FacebookOperations.login(oauth_access_token, profile)
            when 'create'
                resp = FacebookOperations.create_account(oauth_access_token, profile)
            when 'attach'
                resp = FacebookOperations.attach_account(oauth_access_token, profile, @current_user)
            end
            if resp['success']
                user = resp['user']
                if user.session_token_obj.present?
                    cookies[:iom_session_token] = user.session_token_obj
                end
                profile['network'] = 'facebook'
                cookies[:iom_social_profile] = profile
                redirect_to return_params['return_url']
            else
                response.set_cookie(resp)
                redirect_to return_params['return_url']
            end
        else
            # fail profile
            response.set_cookie(profile)
            redirect_to return_params['return_url']
        end
        # respond
    end

    def oauth
        oauth_hsh = oauth_params
        oauth_hsh["network"] = "facebook"
        oauth_hsh["user_id"] = @current_user.id
        save_user = false

        if oauth_hsh['sex'].present? && @current_user.sex.nil?
            @current_user.sex = oauth_hsh['sex']
            save_user = true
        end
        oauth_hsh.delete('sex')

        if oauth_hsh['birthday'].present? && @current_user.birthday.nil?
            puts oauth_hsh['birthday'].inspect
            @current_user.birthday = oauth_hsh['birthday']
            save_user = true
        end
        oauth_hsh.delete('birthday')

        oauth = Oauth.create(oauth_hsh)
        if oauth.persisted?

            if @current_user.facebook_id != oauth.network_id
                @current_user.facebook_id = oauth.network_id
                save_user = true
            end

            if oauth_hsh["photo"].present? && @current_user.get_photo == BLANK_AVATAR_URL
                @current_user.iphone_photo = oauth_hsh["photo"]
                save_user = true
            end

            if save_user
                if @current_user.save
                    success     @current_user.login_client_serialize
                else
                    fail_web    fail_web_payload("not_created_user", @current_user.errors.messages)
                end
            else
                success @current_user.login_client_serialize
            end
        else
            fail_web    fail_web_payload("invalid_facebook", oauth.errors.messages)
            status = :bad_request
        end
        respond(status)
    end

private

    def callback_url_generator token_value
        return  API_URL + "/facebook/callback_url?token=" + token_value
    end

    def ecnew rp
        crypt = ActiveSupport::MessageEncryptor.new(Rails.configuration.secret_key_base, 'Facebook')
        encrypted_data = crypt.encrypt_and_sign(rp.to_json)
        callback_url_generator(encrypted_data)
    end

    def dcnew token
        crypt = ActiveSupport::MessageEncryptor.new(Rails.configuration.secret_key_base, 'Facebook')
        decrypted_back = crypt.decrypt_and_verify(token)
        JSON.parse decrypted_back
    end

    # def encrypt_callback_url request_params
    #     c = OpenSSL::Cipher::Cipher.new("aes-256-cbc")
    #     c.encrypt
    #     c.key = Digest::SHA256.digest('facebook callback')
    #     c.iv = Base64.encode64(Digest::SHA1.hexdigest('fb rules')).chomp
    #     temp_number = c.update(request_params.to_json)
    #     temp_number << c.final
    #     encrypted_data = Base64.encode64(temp_number).chomp
    #     return API_URL + "/facebook/callback_url?token=" + encrypted_data
    # end

    # def decrypt_callback_url request_params
    #     c = OpenSSL::Cipher::Cipher.new("aes-256-cbc")
    #     c.decrypt
    #     c.key = Digest::SHA256.digest('facebook callback')
    #     c.iv = Base64.encode64(Digest::SHA1.hexdigest('fb rules')).chomp
    #     d = c.update(Base64.decode64(request_params['token']))
    #     d << c.final
    #     JSON.parse d
    # end

    def oauth_params
        params.require(:data).permit(:token, :net_id, :photo, :sex, :birthday)
    end
end




