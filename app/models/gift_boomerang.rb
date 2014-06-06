class GiftBoomerang < Gift

    def self.create args={}

        args["payable"] = Gift.find(args["old_gift_id"])
        args.delete("old_gift_id")

        if args["payable"].giver.active == false
            return 'Boomerang does not gift to non-active users'
        end

        gift = super
        if gift.persisted?
            gift.messenger
        end
        gift
    end

    def messenger
        puts "GiftBoomerang-post_init -- Notify new Receiver #{self.receiver}"
        Relay.send_boomerange_push_notification(self)
        puts "GiftBoomerang -messenger- Notify Receiver via email #{self.receiver_name}"
        notify_receiver_boomerang
    end

private

    def boomerang_giver
        "Boomerang"
    end

    def boomerang_message
        "Your friend never created an account so we’re returning this gift. Use Regift to try your friend again, send it to a new friend, use the gift yourself!"
    end

    def pre_init args={}
        old_gift         = args["payable"]
        args["cat"]      = boomerang_cat(old_gift.cat)
        args["giver_name"] = boomerang_giver
        args["giver_type"] = "AdminGiver"
        args["giver_id"] = 7
        args["message"]  = boomerang_message
        args["provider"] = old_gift.provider
        args["value"]    = old_gift.value
        args["service"]  = old_gift.service
        args["cost"]     = old_gift.cost if old_gift.cost
        args["detail"]   = old_gift.detail
        args["shoppingCart"] = old_gift.shoppingCart
        args["pay_stat"]     = old_gift.pay_stat
        remove_receiver_data_and_add_old_gift_giver_as_receiver(args)
        args["receiver"] = old_gift.giver
    end

    def boomerang_cat(cat)
        cat_s   = cat.to_s
        new_cat = cat_s[0..1] + "7"
        new_cat.to_i
    end

    def remove_receiver_data_and_add_old_gift_giver_as_receiver(args)
        ["receiver_name", "receiver_email", "receiver_phone", "twitter", "facebook_id"].each { |key| remove_text(args,key) }
    end

    def remove_text args, key
        if args[key]
            args.delete(key)
        end
    end

end