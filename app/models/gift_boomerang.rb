class GiftBoomerang < Gift
    include GiftMessenger

    def self.create args={}

        args["payable"] = Gift.find(args["old_gift_id"])
        args.delete("old_gift_id")

        if args["payable"].giver.active == false
            return 'Boomerang does not gift to non-active users'
        end

        gift = super
        if gift.persisted?
            gift.messenger_boomerang
        end
        gift
    end

    def original_receiver_social
        if original_receiver = self.payable.receiver
            if original_receiver.email.present?
                original_receiver.email
            elsif original_receiver.phone.present?
                original_receiver.phone
            elsif 
                self.payable.receiver_name
            end
        end
    end

private

    def pre_init args={}
        boom = Boomerang.giver
        old_gift         = args["payable"]
        args["cat"]      = boomerang_cat(old_gift.cat)
        args["giver_name"] = boom.name
        args["giver"]    = boom
        args["message"]  = boom.message
        args["detail"]   = old_gift.detail
        args["provider"] = old_gift.provider
        args["value"]    = old_gift.value
        args["service"]  = old_gift.service
        args["cost"]     = old_gift.cost if old_gift.cost
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