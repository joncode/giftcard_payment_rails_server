class GiftRegift < Gift

    def self.create args={}
        args["old_gift"] = Gift.find(args["old_gift_id"])
        if args["old_gift"].promotional?
            "You cannot regift a promotional gift"
        else
            super
        end
    end

    def pre_init args={}
        @old_gift = args["old_gift"]
        args.delete("old_gift_id")
        args.delete("old_gift")
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