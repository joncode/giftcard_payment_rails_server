class GiftCreator

    attr_reader :gift_hsh, :shoppingCart_str, :shoppingCart_hsh, :giver
    attr_accessor :gift, :resp

    def initialize giver, params_gift, params_shoppingCart
        @giver            = giver
        @shoppingCart_str = stringify_if_ary_or_hsh params_shoppingCart
        @gift_hsh         = convert_if_json params_gift
        @shoppingCart_hsh = convert_if_json params_shoppingCart
        @resp         = {}
    end

    def build_gift_obj
        @gift              = Gift.new(@gift_hsh)
        @gift.shoppingCart = @shoppingCart_str
        @gift.add_giver(@giver)
        puts "Here is GIFT_CREATOR @GIFT  #{@gift.inspect}"
    end

    def add_receiver
            # add the receiver + receiver checks to the gift object
        if @gift.receiver_id.nil?
            add_receiver_object
        else
            # check that the receiver_id is active
            if receiver = User.unscoped.find(@gift.receiver_id.to_i)
                if receiver.active == false
                    @resp["error"] = 'User is no longer in the system , please gift to them with phone, email, facebook, or twitter'
                    @gift.receiver_id = nil
                    @gift.receiver_name = nil
                else
                    @gift.add_receiver receiver
                end
            end
        end
        @resp
    end


#/---------------------------------------------------------------------------------------------/

    def charge
        @gift.charge_card
        if @gift.save
            if @gift.sale.resp_code == 1
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


    def regift
        @recipient_data = JSON.parse @gift_json["receiver"]
        @details        = JSON.parse @gift_json["data"]
        @message        = details["message"]
        old_gift_id     = self.details["regift_id"]
        recipient       = nil

        if self.recipient_data["receiver_id"] && self.recipient_data["receiver_id"] > 0
            unless recipient = User.find(self.recipient_data["receiver_id"])
                puts "!!! APP SUBMITTED USER ID THAT DOESNT EXIST #{recipient_data} !!!"
                recipient = make_user_with_hash(self.recipient_data)
            end
        else
            recipient = make_user_with_hash(self.recipient_data)
        end

        if recipient && (old_gift = Gift.find(old_gift_id.to_i))
            new_gift = old_gift.regift(recipient, message)
            new_gift.save
            old_gift.update_attribute(:status, 'regifted')
            new_gift.set_status
            new_gift.save
        else
            new_gift = nil
        end

        new_gift
    end

    def promotional

    end

#/---------------------------------------------------------------------------------------------/

    def no_data?
        if @gift_hsh.kind_of?(Hash) && @shoppingCart_hsh.kind_of?(Array)
            return false
        else
            @resp["error_server"] = database_error_gift
            return true
        end
    end

#     Lifecycle :
#     JSON string of gift info received
#     confirms info of the giver
    def giver gift_obj
        gift_obj.nil?
    end
#     checks the validity of the total and service vs the shopping cart
    def money s_cart
        s_cart.nil?
    end
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
    def messenger
        if Rails.env.test?
            puts "send notify_receiver"
            if @gift.regift_id.nil?
                puts "send invoice_giver"
            end
            if @gift.receiver_id
                puts " send Relay.send_push_notification @gift"
            end
        else
            notify_receiver
            if @gift.regift_id.nil?
                invoice_giver
            end
            if @gift.receiver_id
                Relay.send_push_notification @gift
            end
        end
#         - new gift message to the merchant
#         - alert campaign if CAMPAIGN
#         - sends text to receiver
#         - sends message thru fb, twitter to receiver
#         - post to drinkboard gifts twitter
    end

private

    def make_user_with_hash(user_data_hash)
        recipient               = User.new
        recipient.first_name    = user_data_hash["name"]
        recipient.email         = user_data_hash["email"]
        recipient.phone         = user_data_hash["phone"]
        recipient.facebook_id   = user_data_hash["facebook_id"]
        recipient.twitter       = user_data_hash["twitter"]
        return recipient
    end

    def convert_if_json params
        if params.kind_of?(String)
            JSON.parse(params)
        elsif params.kind_of?(Hash) || params.kind_of?(Array)
            params
        else
            nil
        end
    end

    def stringify_if_ary_or_hsh params
        if params.kind_of?(String)
            params
        elsif params.kind_of?(Hash) || params.kind_of?(Array)
            params.to_json
        else
            nil
        end
    end

    def add_receiver_object

        unique_ids = [ ["phone", @gift.receiver_phone], ["facebook_id", @gift.facebook_id],["email", @gift.receiver_email], ["twitter", @gift.twitter ] ]
        unique_ids.each do |unique_id|
            type_of = unique_id[0]
            if unique_id[1].present?
                if find_user(type_of, unique_id[1])
                    # stop when you find a user
                    break
                end
            end
        end
    end

    def find_user type_of, unique_id
        method_is = "find_by_#{type_of}"
        if receiver = User.send(method_is, unique_id)
            @gift.add_receiver receiver
            @resp["receiver"] = receiver_info_resp(receiver)
            @resp["origin"]   = type_of
            return true
        else
            @resp["origin"]   = "NID"
            return false
        end
    end

    def receiver_info_resp receiver
        { "receiver_id" => receiver.id.to_s, "receiver_name" => receiver.username, "receiver_phone" => receiver.phone }
    end


end







