class MoveRegiftDataToPayableOnGifts < ActiveRecord::Migration
  def up
      # moving the old gift onto the payable of the new gift
    regifts = Gift.unscoped.where(status: "regifted")
    regifts.each do |old_gift|
        new_gift = Gift.find(old_gift.regift_id)
        new_gift.payable = old_gift
        unless new_gift.save
            puts  "NEW GIFT FAIL --------- NEW GIFT FAIL --------- gift ID #{new_gift.id} ------------- NEW GIFT FAIL -------------- NEW GIFT FAIL\n"
        end
    end
  end

  def down

  end
end
