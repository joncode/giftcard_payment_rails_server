class CalculateCatToLegacyGifts < ActiveRecord::Migration
    def up
        gifts = Gift.unscoped
        gifts.each do |gift|
            case gift.payable_type
            when "Sale"
                # do nothing
            when "Gift"
                gift.cat = 100
            when "Debt"
                gift.cat = gift.giver_type == "BizUser" ? 200 : 210
            end
            gift.save
        end
    end

    def down
        # no reason to undo the cat values
        gifts = Gift.unscoped
        gifts.each do |gift|
            gift.update(cat: 0)
        end
    end
end
