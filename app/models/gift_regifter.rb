class GiftRegifter < GiftUtility

    attr_accessor :old_gift, :gift, :resp

    def initialize(recipient_hsh , details)
        @old_gift     = Gift.includes(:receiver).find(details['regift_id'])
        setup_regift(details['message'])
        @resp         = {}


        recipient     = make_user_with_hash(recipient_hsh)
        add_receiver_from_hash(recipient)
        
    end


    def create
        if @gift.save
            @resp["success"] = @gift.serialize
            messenger
            true
        else
            @resp["error_server"] = @gift.errors.messages
            false
        end
    end

    def response
        if @resp.has_key? "error"
            return @resp["error"]
        elsif @resp.has_key? "success"
            return @resp["success"]
        else
            return @resp["error_server"]
        end
    end

private

    def setup_regift(message=nil)
        @gift              = @old_gift.dup
        @gift.regift_id    = @old_gift.id
        @gift.add_giver(@old_gift.receiver)
        @gift.remove_receiver
        @gift.message      = message ? message : nil
        @gift.order_num    = nil
        @gift.pay_type     = "Regift"
    end

end