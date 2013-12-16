class MoveRegiftDataToPayableOnGifts < ActiveRecord::Migration
  def up
      # moving the old gift onto the payable of the new gift
    # regifts = Gift.unscoped.where(status: "regifted")
    # total = regifts.count
    # good = 0
    # bad = 0
    # no_gift = 0
    # regifts.each do |old_gift|
    #    puts "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    #     new_gift = old_gift.child
    #     if new_gift
    #       new_gift.payable = old_gift
    #       if new_gift.save
    #         good += 1
    #       else
    #         bad += 1
    #           puts  "NEW GIFT FAIL --------- NEW GIFT FAIL --------- gift ID #{new_gift.id} #{new_gift.errors.full_messages} ------------- NEW GIFT FAIL -------------- NEW GIFT FAIL\n"
    #       end
    #     else
    #       no_gift += 1
    #       puts "NO NEW GIFT FOR ------------------------------->>>>>> #{old_gift.id}"

    #     end
    #      puts "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    # end

    #     puts "MOVE Regift gift to payable"
    #     puts "Updated = #{good}"
    #     puts "Total = #{total}"
    #     puts "Not Saved = #{bad}"
    #     tot = good + bad + no_gift
    #     puts "Counted = #{tot}"
    #     puts "regift with no child #{no_gift}"
  end

  def down

  end
end
