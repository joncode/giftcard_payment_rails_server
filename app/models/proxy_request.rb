class ProxyRequest
    include HTTParty
    base_uri SOCIAL_PROXY_URL

    attr_accessor :resp

    def initialize params, token
        #@auth = {:username => SLICKTEXT_PUBLIC, :password => SLICKTEXT_PRIVATE}
        @params = params
        @token = token
        @resp = nil
    end

    def sms  options={}
        options.merge!(@params)
        self.resp = self.class.post("/twitter/friends", options)
        puts self.resp.inspect
        self.resp
    end

end