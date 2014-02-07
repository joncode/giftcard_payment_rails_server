class GiftAdmin < Gift


private

    def pre_init args={}
        args["value"]   = calculate_value(args["shoppingCart"], "price")
        args["cost"]   = calculate_value(args["shoppingCart"], "price_promo")
        giver = args["giver"]
        args["payable"] = giver.new_debt(args["value"])
    end

    def post_init args={}
        puts "NOTIFY RECEIVER VIA #{self.receiver_email}"
    end

    def calculate_value shoppingCart_string, price_type
        sc = JSON.parse shoppingCart_string
        sc.sum {|z| z[price_type].to_i * z["quantity"].to_i }
    end

end