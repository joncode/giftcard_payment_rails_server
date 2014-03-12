class SocialProxy
    include HttpModel

    attr_reader   :token, :network_id, :network, :handle, :secret
    attr_accessor :status, :data, :msg

    def initialize args={}
        @token      = args["token"]
        @network_id = args["network_id"]
        @network    = args["network"]
        @secret     = args["secret"]
        @handle     = args["handle"]
        @status = nil
        @data   = nil
        @msg    = nil
    end

    def valid?
        token.nil?      and return false
        network_id.nil? and return false
        network.nil?    and return false
        if network == "twitter"
            secret.nil? and return false
            handle.nil? and return false
        end
        return true
    end

    def friends
        route  = SOCIAL_PROXY_URL + "/#{self.network}/friends"
        resp   = post(token: get_token, params: get_key_params, route: route)
        self.status = resp["status"]
        self.msg    = resp["msg"]
        if resp["data"].class == String
            self.data = JSON.parse resp["data"]
        else
            self.data = resp["data"]
        end
        self
    end

    def profile
        route  = if self.network == "twitter"
            SOCIAL_PROXY_URL + "/#{self.network}/account"
        else
            SOCIAL_PROXY_URL + "/#{self.network}/profile"
        end
        resp   = post(token: get_token, params: get_key_params, route: route)
        set_instance resp
    end

    def create_post args={}
        route  = if self.network == "twitter"
            SOCIAL_PROXY_URL + "/#{self.network}/mention"
        else
            SOCIAL_PROXY_URL + "/#{self.network}/story"
        end
        resp   = post(token: get_token, params: get_params, route: route)
        set_instance resp
    end

private

    def set_instance resp
        self.status = resp["status"]
        self.data   = resp["data"]
        self.msg    = resp["msg"]
        self
    end

    def get_token
        SOCIAL_PROXY_TOKEN
    end

    def get_key_params
        hsh = {}
        hsh["network_id"]   = self.network_id
        hsh["token"]        = self.token
        hsh["secret"]       = self.secret if self.secret
        hsh
    end

    def get_params
        hsh = {}
        hsh["token"]        = self.token
        hsh["secret"]       = self.secret if self.secret
        hsh["network_id"]   = self.network_id
        hsh["handle"]       = self.handle if self.handle
        hsh
    end

end

# POST      /api/facebook/profile
# POST      /api/facebook/friends
# POST      /api/facebook/story
# POST      /api/twitter/account
# POST      /api/twitter/friends
# POST      /api/twitter/mention