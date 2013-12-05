class GiftRegift < Gift

    def self.create args={}
        args["payable"] = Gift.includes(:provider).includes(:receiver).find(args["old_gift_id"])
        if args["payable"].promo?
            "You cannot regift a promotional gift"
        else
            super
        end
    end

private

    def pre_init args={}
        args.delete("old_gift_id")
        @old_gift = args["payable"]
        args["giver"]    = @old_gift.receiver
        args["provider"] = @old_gift.provider
        args["value"]    = @old_gift.value
        args["shoppingCart"] = @old_gift.shoppingCart
        args["pay_stat"] = @old_gift.pay_stat
        user_to_gift_key_names args
    end

    def post_init args={}
        puts "REGIFT-post_init -- Notify new Receiver #{self.receiver}"
        puts "REGIFT-post_init -- Invoice the regifter via email #{self.giver}"
    end

    def user_to_gift_key_names args
        ["name", "email", "phone"].each { |key| remove_text(args,key) }
    end

    def remove_text args, key
        if args[key]
            args["receiver_#{key}"] = args[key]
            args.delete(key)
        end
    end

end