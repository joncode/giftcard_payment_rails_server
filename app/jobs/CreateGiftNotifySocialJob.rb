class CreateGiftNotifySocial

    @queue = :social

    def perform gift_id
        puts " -------------   Notify Social Create Gift --------------------"
        if gift = self.gift
            cart     = JSON.parse gift.shoppingCart
            post_hsh = { "merchant"  => gift.provider_name, "title" => cart[0]["item_name"], "url" => "#{PUBLIC_URL}/signup/acceptgift/#{gift.obscured_id}" }
            social_proxy = SocialProxy.new(self.to_proxy)
            social_proxy.create_post(post_hsh)
        end
    end

end