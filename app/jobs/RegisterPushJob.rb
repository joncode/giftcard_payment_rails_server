class RegisterPushJob

    @queue = :push

    def self.perform pn_token_id
        pn_token    = PnToken.find pn_token_id
        user_alias  = pn_token.ua_alias
        puts "registering PN Token for #{pn_token.user.name}"
        resp = Urbanairship.register_device(pn_token.pn_token, :alias => user_alias )
        puts "UA response --- >  #{resp}"
    end

end