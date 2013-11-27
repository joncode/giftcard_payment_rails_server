class GiftRegift < Gift

    def pre_init args={}
        old_gift         = Gift.find(args["old_gift_id"])
        args.delete("old_gift_id")
        args["giver"]    = old_gift.receiver
        args["provider"] = old_gift.provider
        args["value"]    = old_gift.value

    end

    def post_init args={}
        puts "Notify new Receiver #{self.receiver}"
        puts "Invoice the regifter via email #{self.giver}"
    end


end