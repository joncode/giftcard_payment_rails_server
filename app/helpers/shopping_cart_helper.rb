module ShoppingCartHelper

    def calculate_value shoppingCart_string
        sc = JSON.parse shoppingCart_string
        sc.sum {|z| z["price"].to_i * z["quantity"].to_i }.to_s
    end

    def calculate_cost shoppingCart_string
    	sc = JSON.parse shoppingCart_string
        sc.sum do |z|
            if z["price_promo"].present?
                z["price_promo"].to_f * z["quantity"].to_i
            else
                z["price"].to_f * 0.85 * z["quantity"].to_i
            end
        end
    end
end