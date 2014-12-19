#require 'resque/plugins/resque_heroku_autoscaler'

class CreateGiftNotifySocial
    #extend Resque::Plugins::HerokuAutoscaler

    @queue = :push

    def self.perform gift_id
        puts " -------------   Notify Social Create Gift --------------------"
        if gift = Gift.find(gift_id)
            oauth = gift.oauth
            cart     = JSON.parse gift.shoppingCart
            post_hsh = { "merchant"  => gift.provider_name, "title" => cart[0]["item_name"], "url" => "#{PUBLIC_URL}/signup/acceptgift?id=#{gift.obscured_id}" }
            social_proxy = SocialProxy.new(oauth.to_proxy)
            social_proxy.create_post(post_hsh)
            puts "------ #{social_proxy.msg}"
        end
    end

end