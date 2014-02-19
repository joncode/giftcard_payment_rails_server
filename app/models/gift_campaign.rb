class GiftCampaign < Gift




private

    def pre_init args={}
        shoppingCart = JSON.parse args["shoppingCart"]
        args["value"]   = calculate_value(shoppingCart)
        args["cost"]    = calculate_cost(shoppingCart)
        giver = args["giver"]
        args["payable"] = giver.new_debt(args["value"])
    end

    def post_init args={}
        puts "NOTIFY RECEIVER VIA #{self.receiver_email}"
    end

    def calculate_value shoppingCart
        shoppingCart.sum {|z| z["price"].to_i * z["quantity"].to_i }
    end

    def calculate_cost shoppingCart
        shoppingCart.sum {|z| z["price_promo"].to_f * z["quantity"].to_i }
    end
    
end