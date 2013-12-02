class GiftCreator < GiftUtility

    attr_reader   :gift_hsh, :shoppingCart_str, :shoppingCart_hsh, :giver
    attr_accessor :gift, :resp

    def initialize giver, params_gift, params_shoppingCart
        @giver            = giver
        @shoppingCart_str = stringify_if_ary_or_hsh params_shoppingCart
        @gift_hsh         = convert_if_json params_gift
        @shoppingCart_hsh = convert_if_json params_shoppingCart
        @resp             = {}
    end

    def build_gift
        @gift              = Gift.new(@gift_hsh)
        @gift.shoppingCart = @shoppingCart_str
        @gift.add_giver(@giver)
        add_receiver
    end

    def charge
        @gift.charge_card
        if @gift.save
            if @gift.payable.resp_code == 1
                @resp["success"]       = { "Gift_id" => @gift.id }
                messenger
            else
                @resp["error_server"]  = { "Credit Card" => @gift.sale.reason_text }
            end
        else
            @resp["error_server"] = @gift.errors.messages
        end
        @resp
    end


#/---------------------------------------------------------------------------------------------/

    def no_data?
        if @gift_hsh.kind_of?(Hash) && @shoppingCart_hsh.kind_of?(Array)
            return false
        else
            @resp["error_server"] = { "Data Transfer Error"   => "Please Retry Sending Gift" }
            return true
        end
    end

end

#     Lifecycle :
#     JSON string of gift info received
#     confirms info of the giver
#     checks the validity of the total and service vs the shopping cart
#     confirms the credit card
#     checks the receiver for db_user or non
#     saves the gift_items off the shopping cart
#     creates the payment record OR returns false payment info
#         charges card SALE
#         debts credit CREDITACCOUNT
#         debts campaign CAMPAIGN
#     creates the gift record OR returns failure to create gift OR retries
#     sets appropriate statuses
#     saves the gift record
#     sends the messages








