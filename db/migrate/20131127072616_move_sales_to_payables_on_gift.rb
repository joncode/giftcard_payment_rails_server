class MoveSalesToPayablesOnGift < ActiveRecord::Migration

    def up
        # gs = Gift.unscoped
        # total = gs.count
        # good = 0
        # bad = 0
        # save = 0
        # gs.each do |gift|
        #     gift.giver = User.unscoped.find(gift.giver_id)
        #     gift.value = gift.total
        #     puts "HERE IS VALUE ___________________ #{gift.value}"
        #     payable = gift.sale
        #     if payable
        #       good += 1
        #       gift.payable = payable
        #     end
        #     if  gift.save
        #         puts "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
        #         puts "#{gift.id} / #{gift.value} / #{gift.total} / #{gift.giver_type}"
        #         save += 1
        #     else
        #       bad += 1
        #         puts "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
        #         puts "FAIL --------- FAIL --------- gift ID #{gift.id} #{gift.errors.full_messages} #{gift.status}------------- FAIL -------------- FAIL"
        #         puts "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
        #     end
        # end
        # puts "MOVE Giver type and value / make payable a sale"
        # puts "Updated = #{good}"
        # puts "Saved = #{save}"
        # puts "Total = #{total}"
        # puts "No Saves = #{bad}"
        # tot = good + bad
        # puts "Counted = #{tot}"
    end

    def down
        # nothing
    end
end
