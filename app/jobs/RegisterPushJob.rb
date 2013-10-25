class RegisterPushJob

    @queue = :push

    def self.perform pn_token_id
        pn_token    = PnToken.find pn_token_id
        user_alias  = pn_token.user.ua_alias
        puts "registering PN Token for #{pn_token.user.name}"
        Urbanairship.register_device(self.pn_token, :alias => user_alias )
    end

end