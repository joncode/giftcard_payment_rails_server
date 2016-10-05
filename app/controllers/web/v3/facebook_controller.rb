class Web::V3::FacebookController < MetalCorsController
    include ERB::Util

    # before_action :authentication_no_token
    # before_action :get_current_user_fb_oauth, except: :oauth
    before_action :authentication_token_required, except: [ :oauth_init, :callback_url, :share ]
    rescue_from JSON::ParserError, :with => :bad_request

    def share
        user_id = share_params[:user_id]
        menu_item_id = share_params[:menu_item_id]
        user_action = share_params[:user_action]
        network_id = share_params[:facebook_share_id]
        if network_id.nil?
            fail("Facebook Share ID not received")
        else
            s = Share.where(network_id: network_id).first
            if s.nil?
                # make new share
                s = Share.create(user_id: user_id,
                            menu_item_id: menu_item_id,
                            user_action: 'share',
                            network_id: network_id,
                            count: 1)
            else
                # add count to share
                s.increment!(:count)
            end
            success("share saved #{network_id}")
        end
        respond
    end

    def app_friends
        resp = OpsFacebook.app_friends(@current_user)
        if resp['success']
            success(resp['data'])
        else
            fail(resp['error'])
            @app_response["msg"] = resp['error']
        end
        respond
    end

    def friends
        resp = OpsFacebook.friends(@current_user)
        if resp['success']
            success(resp['data'])
        else
            fail(resp['error'])
            @app_response["msg"] = resp['error']
        end
        respond
    end

    def taggable_friends
        resp = OpsFacebook.taggable_friends(@current_user)
        if resp['success']
            success(resp['data'])
        else
            fail(resp['error'])
            @app_response["msg"] = resp['error']
        end
        respond
    end

    def profile
        resp = OpsFacebook.profile(@current_user, params['facebook_id'])
        if resp['success']
            success(resp['data'])
        else
            fail(resp['error'])
            @app_response["msg"] = resp['error']
        end
        respond
    end

    def create
        oauth_obj = @current_user.current_oauth
        if oauth_obj.kind_of?(Oauth)
            graph = Koala::Facebook::API.new(oauth_obj.token, FACEBOOK_APP_SECRET)
            post_id_hsh = graph.put_wall_post( "You've Received a Gift!", { :link => "#{PUBLIC_URL}/hi/#{gift_obscured_id}" })
                # WTF IS THIS ^^^^^^  WHATS :gift_obscured_id ???????????
            success 'Facebook Post Successful'
            respond
        else
            fail    "Facebook profile token expired"
            @app_response["msg"] = "Please re-authenticate Facebook"
            status = 404
            respond(status)
        end
    end

    def oauth_init
        oauth = Koala::Facebook::OAuth.new(FACEBOOK_APP_ID, FACEBOOK_APP_SECRET, callback_url_generator(generate_token(params)))
        scope_ary = OpsFacebook.permissions
        redirect_url = oauth.url_for_oauth_code(scope: scope_ary )
        # success redirect_url
        # respond(:found)
        redirect_to redirect_url
    end

    def callback_url
        decoded_token = params['token']
        url_safe_token = url_encode(decoded_token)
        # puts "\n TOKEN ----- \n#{params['token']} \n  CODE ----------  \n#{params['code']}  \n"
        oauth = Koala::Facebook::OAuth.new(FACEBOOK_APP_ID, FACEBOOK_APP_SECRET, callback_url_generator(url_safe_token))
        if params['error'].present? || params['error_code'].present? || params['error_subcode']
            # {"token"=>"[FILTERED]",
            # "error_code"=>"1349127",
            # "error_message"=>"We could not log you in: You can't log in to this app because you do not meet this app's requirements for country, age or other criteria."}
            if params['error']
                error_param = "?error=#{url_encode(params['error'])}&error_reason=#{url_encode(params['error_reason'])}"
            elsif params['error_code']
                error_param = "?error=#{url_encode(params['error_code'])}&error_reason=#{url_encode(params['error_message'])}"
            else
                error_param = "?error=#{url_encode(params['error_subcode'])}&error_reason=#{url_encode(params['message'])}"
            end
            return_params = decrypt_token(url_safe_token)
            full_response_url = return_params['return_url'].to_s + error_param
            redirect_to full_response_url
        else
            begin
                oauth_access_token = oauth.get_access_token(params['code'])
            rescue
                puts "500 Internal - here are the params #{params.inspect}"
                error_param = "?error=400&error_reason=invalid_verification_code_format"
                full_response_url = return_params['return_url'].to_s + error_param
                redirect_to full_response_url
            end
            begin
                graph = Koala::Facebook::API.new(oauth_access_token, FACEBOOK_APP_SECRET)
                profile = graph.get_object("me")
            rescue
                graph = Koala::Facebook::API.new(oauth_access_token)
                profile = graph.get_object("me")
            end
            puts profile.inspect

            return_params = decrypt_token(url_safe_token)
            puts return_params.inspect

            if profile['id'].present?
                add_token = false
                @current_client = Client.includes(:partner).find_by(application_key: return_params['client'])
                @current_partner = @current_client.partner
                case return_params['operation']
                when 'login'
                    resp = OpsFacebook.login(oauth_access_token, profile)
                    puts resp.inspect
                    add_token = true
                when 'create'
                    resp = OpsFacebook.create_account(oauth_access_token, profile, @current_client, @current_partner )
                    add_token = true
                when 'attach'
                    @current_user = SessionToken.app_authenticate(return_params['auth'])
                    if @current_user.nil?
                        resp = { 'success' => false , 'error' => 'Could not authenticate user' }
                    else
                        resp = OpsFacebook.attach_account(oauth_access_token, profile, @current_user)
                    end
                else
                    resp = { 'success' => false , 'error' => 'No operation specified' }
                end
                if resp['success']
                    user = resp['user']
                    if add_token
                        user.session_token_obj =  SessionToken.create_token_obj(user, 'fb', nil, @current_client, @current_partner)
                        SessionBeginJob.perform(@current_client.id, user) if return_params['operation'] == 'login'
                        session_token_param = "&session_token=#{user.session_token_obj.token}"
                    else
                        session_token_param = ""
                    end
                    facebook_param = "?facebook_id=#{profile['id']}"
                    full_response_url = return_params['return_url'] + facebook_param + session_token_param
                    redirect_to full_response_url
                else
                    error_param = "?error=#{url_encode(resp['error'])}"
                    full_response_url = return_params['return_url'] + error_param
                    redirect_to full_response_url
                end
            else
                # fail profile
                full_response_url = return_params['return_url'] + "?error=no_facebook_profile"
                redirect_to return_params['return_url']
            end
            # respond
        end
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
        url = API_URL + "/facebook/callback_url?token=" + token_value
        # puts "\n\n ---------   \n#{url.inspect}  \n\n ---------- \n"
        return url
    end

    def generate_token rp
        crypt = ActiveSupport::MessageEncryptor.new(Rails.configuration.secret_key_base, 'Facebook')
        not_url_safe_token = crypt.encrypt_and_sign(rp.to_json)
        # puts "\n raw token \n #{not_url_safe_token}"
        safe_token = url_encode(not_url_safe_token)
        # puts "\n safe token \n #{safe_token}"
        return safe_token
    end

    def decrypt_token url_safe_token
        not_url_safe_token = URI.decode(url_safe_token)
        crypt = ActiveSupport::MessageEncryptor.new(Rails.configuration.secret_key_base, 'Facebook')
        decrypted_back = crypt.decrypt_and_verify(not_url_safe_token)
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

    def share_params
        params.require(:data).permit(:facebook_share_id, :user_action, :menu_item_id, :user_id)
    end

    def oauth_params
        params.require(:data).permit(:token, :net_id, :photo, :sex, :birthday)
    end
end




