class GiftRedemptionJob
    @queue = :after_save

    def self.perform gift_id
        gift = Gift.unscoped.find gift_id
        gift.redeem_gift
    end
end