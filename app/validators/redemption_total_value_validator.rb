class RedemptionTotalValueValidator < ActiveModel::Validator

    def validate(record)
        gift = record.gift
        if gift.kind_of?(Gift)
            total_value = gift.value_in_cents
            already_redeemed_value = Redemption.where(gift_id: gift.id).sum(:amount) + record.amount
            if already_redeemed_value - total_value > 0
                return record.errors[:amount] << "Gift has value has already been redeemed"
            end
        else
            return record.errors[:gift] << "Gift not found. Cannot redeemed."
        end
    end

end


