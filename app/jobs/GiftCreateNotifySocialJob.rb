#require 'resque/plugins/resque_heroku_autoscaler'

class GiftCreateNotifySocial
    #extend Resque::Plugins::HerokuAutoscaler

    @queue = :push

    def self.perform gift_id
        puts " -------------   Notify Social Create Gift --------------------"
        if gift = Gift.find(gift_id)
            oauth = gift.oauth
            cart     = JSON.parse gift.shoppingCart
            post_hsh = { "merchant"  => gift.provider_name, "title" => cart[0]["item_name"], "link" => "#{PUBLIC_URL}/signup/acceptgift?id=#{gift.obscured_id}", "url" => "#{PUBLIC_URL}/signup/acceptgift?id=#{gift.obscured_id}" }
            # social_proxy = SocialProxy.new(oauth.to_proxy)
            # social_proxy.create_post(post_hsh)
            # puts "------ #{social_proxy.msg}"

            giver = gift.giver
            oauth_obj = giver.current_oauth
            graph = Koala::Facebook::API.new(oauth_obj.token, FACEBOOK_APP_SECRET)
            post_id_hsh = graph.put_wall_post( "You've Received a Gift!", post_hsh, gift.facebook_id)
            puts "POSTED TO FACEBOOK WALL GiftCreateNotifySocial#{post_id_hsh}\n"

        end
    end

end