class RedemptionTotalValueValidator < ActiveModel::Validator

    include ShoppingCartHelper
    include MoneyHelper

    def validate(record)
        gift = record.gift
        if gift.kind_of?(Gift)
            # this is not toal value its current value - BUG
            total_value = currency_to_cents(calculate_value(gift.shoppingCart))
            already_redeemed_value = Redemption.where(gift_id: gift.id).sum(:amount) + record.amount
            if already_redeemed_value - total_value > 0
                return record.errors[:amount] << "Gift has value has already been redeemed"
            end
        else
            return record.errors[:gift] << "Gift not found. Cannot redeemed."
        end
    end

end


