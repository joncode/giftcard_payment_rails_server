class ChangeRegiftDataOnGifts < ActiveRecord::Migration
    def up
        # gs = Gift.unscoped
        # regifts = gs.select{|g| !g.regift_id.nil? }
        # regifts.each do |gift|
        #     parent = gift.parent
        #     gift.payable = parent
        #     gift.save
        # end
    end

    def down
        # no data erased so nothing necessary
    end
end
