module ShoppingCartHelper

    def calculate_value shoppingCart_string
        sc = JSON.parse shoppingCart_string
        sc.sum {|z| z["price"].to_i * z["quantity"].to_i }.to_s
    end

    def calculate_cost shoppingCart_string, merchant
        sc = JSON.parse shoppingCart_string
        cost_as_f = sc.sum do |z|
            if z["price_promo"].present? && (z["price_promo"].to_f < (z["price"].to_f * merchant.location_fee))
                z["price_promo"].to_f * z["quantity"].to_i
            else
                z["price"].to_f * merchant.location_fee.to_f * z["quantity"].to_i
            end
        end
        cost_as_f.to_s
    end

    def items
        cart_ary.count
    end

    def cart_ary
        begin
            JSON.parse(self.shoppingCart)
        rescue
            []
        end
    end

end