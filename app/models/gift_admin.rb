class GiftAdmin < Gift


private

    def pre_init args={}
        args["value"]   = calculate_value(args["shoppingCart"])
        giver = args["giver"]
        args["payable"] = giver.new_debt(args["value"])
    end

    def post_init args={}
        puts "NOTIFY RECEIVER VIA #{self.receiver_email}"
    end

    def calculate_value shoppingCart_string
        sc = JSON.parse shoppingCart_string
        sc.sum {|z| z["price"].to_i * z["quantity"].to_i }
    end

end