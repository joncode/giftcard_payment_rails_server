class GiftPromo < Gift

    def pre_init args={}
        giver           = BizUser.find(args["provider_id"])
        args["giver"]   = giver
        args["payable"] = giver.new_debt(args["value"])
    end

    def post_init args={}
        puts "NOTIFY RECEIVER VIA #{self.receiver_email}"
    end

end