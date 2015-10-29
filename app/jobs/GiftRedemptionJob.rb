class GiftRedemptionJob
    @queue = :after_save

    def self.perform gift_id
        gift = Gift.find params[:id]
        gift.redeem_gift
    end
end