module ShoppingCartHelper

    def calculate_value shoppingCart_string
        sc = JSON.parse shoppingCart_string
        sc.sum {|z| z["price"].to_f * z["quantity"].to_i }.to_s
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

    def cart_ary shoppingCart_string=nil
        if shoppingCart_string
            JSON.parse shoppingCart_string
        elsif self.shoppingCart
            JSON.parse self.shoppingCart
        else
            []
        end
    end
    alias_method :cart, :cart_ary
    alias_method :sc, :cart_ary

    def stringify_shopping_cart_if_array shoppingCart
        if shoppingCart.kind_of?(Array)
            shoppingCart.to_json
        else
            shoppingCart
        end
    end

end