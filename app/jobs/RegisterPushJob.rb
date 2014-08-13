require 'resque/plugins/resque_heroku_autoscaler'

class RegisterPushJob
    extend UrbanAirshipWrap
    #extend Resque::Plugins::HerokuAutoscaler

    @queue = :push

    def self.perform pn_token_id
        pn_token    = PnToken.find pn_token_id
        puts "registering PN Token for #{pn_token.user.name}"
        self.ua_register(pn_token.pn_token, pn_token.ua_alias, pn_token.user_id, pn_token.platform)
    end

end