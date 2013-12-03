class GiftRegift < Gift

    def self.create args={}
        args["payable"] = Gift.find(args["old_gift_id"])
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
        args["pay_stat"] = @old_gift.pay_stat
    end

    def post_init args={}
        puts "Notify new Receiver #{self.receiver}"
        puts "Invoice the regifter via email #{self.giver}"
    end

end