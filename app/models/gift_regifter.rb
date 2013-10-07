class GiftRegifter < GiftUtility

    attr_accessor :old_gift, :gift, :resp

    def initialize(recipient_hsh , details)
        @old_gift     = Gift.includes(:receiver).find(details['regift_id'])
        @giver        = @old_gift.receiver
        setup_regift
        @resp         = {}
        recipient     = make_user_with_hash(recipient_hsh)
        add_receiver_from_hash(recipient)
        @gift.message = details['message']
    end


    def create
        if @gift.save
            @resp["success"]      = @gift.serialize
            messenger
            true
        else
            @resp["error_server"] = @gift.errors.messages
            false
        end
    end



private

    def setup_regift
        @gift              = @old_gift.dup
        @gift.regift_id    = @old_gift.id
        @gift.add_giver(@old_gift.receiver)
        @gift.remove_receiver
        @gift.message      = @message ? @message : nil
        @gift.order_num    = nil
    end

end